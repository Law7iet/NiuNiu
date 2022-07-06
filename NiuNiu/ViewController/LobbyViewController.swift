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
    
    var playersInLobby: PeerList = PeerList()
    @IBOutlet weak var playersTableView: UITableView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playersInLobby.list.append(hostPeerID)
        self.playersInLobby.list.append(myPeerID)
        self.mcSession.delegate = self
        
        self.playersTableView.dataSource = self
    }
    
    // MARK: Supporting functions
    func addPlayerWith(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.playersInLobby.list.count, section: 0)
        self.playersInLobby.list.append(peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removePlayerWith(indexPath: IndexPath) {
        self.playersInLobby.list.remove(at: indexPath.row)
        self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Actions
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension LobbyViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersInLobby.list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lobbyCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = self.playersInLobby.convertListToString()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

extension LobbyViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.addPlayerWith(peerID: peerID)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                if let index = self.playersInLobby.list.firstIndex(of: peerID) {
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
