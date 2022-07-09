//
//  ClientViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

import UIKit
import MultipeerConnectivity

class ClientViewController: UIViewController {

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the data
        if let vc = segue.destination as? ClientGameViewController {
            vc.users = self.playersInLobby
            vc.mcSession = self.mcSession
            vc.myPeerID = self.myPeerID
            vc.hostPeerID = self.hostPeerID
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
extension ClientViewController: UITableViewDataSource {
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
extension ClientViewController: MCSessionDelegate {
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
        let gameMessage = Message(data: data)
        switch gameMessage.type {
        case .closeLobby:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The lobby has been closed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.mcSession.disconnect()
            }
        case .closeConnection:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The host removed you from the lobby", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.mcSession.disconnect()
            }
        case .startGame:
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showClientGameSegue", sender: nil)
            }
        case .testMessage:
            print("Ack")
        default:
            print("Errore")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}
