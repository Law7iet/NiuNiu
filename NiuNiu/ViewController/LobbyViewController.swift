//
//  LobbyViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

import UIKit
import MultipeerConnectivity

class LobbyViewController: UIViewController {

    // MARK: Variables
    var myPeerID: MCPeerID!
    var hostPeerID: MCPeerID!
    var mcSession: MCSession!
    
    var playersInLobby: [MCPeerID]!
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupConnectivity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.playersInLobby.append(hostPeerID)
        self.playersInLobby.append(myPeerID)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.playersInLobby.removeAll()
        if self.isMovingFromParent {
            mcSession.disconnect()
        }
    }
    
    // MARK: Supporting functions
    func setupConnectivity() {
        self.playersInLobby = [MCPeerID]()
        self.mcSession.delegate = self
        self.playersTableView.dataSource = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.playersInLobby.count) of 6 players found"
    }
    
    func addPlayerWith(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.playersInLobby.count, section: 0)
        self.playersInLobby.append(peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
    func removePlayerWith(indexPath: IndexPath) {
        self.playersInLobby.remove(at: indexPath.row)
        self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
    // MARK: Actions
}

// MARK: UITableViewDataSource implementation
extension LobbyViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersInLobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lobbyCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: self.playersInLobby)[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: MCSessionDelegate implementation
extension LobbyViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                if peerID != self.hostPeerID {
                    self.addPlayerWith(peerID: peerID)
                }
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                if let index = self.playersInLobby.firstIndex(of: peerID) {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.removePlayerWith(indexPath: indexPath)
                }
            }
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}
