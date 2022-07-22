//
//  LobbyViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

import UIKit
import MultipeerConnectivity

class ClientLobbyVC: UIViewController {

    // MARK: Properties
    var comms: Client!
    var lobby: Lobby!
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.comms.lobbyDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lobby.clearUsers(withPeers: [comms.hostPeerID!, comms.himselfPeerID])
        self.playersTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.comms.disconnect()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the manager
        if let clientVC = segue.destination as? ClientGameVC {
            clientVC.comms = self.comms
        }
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.lobby.count) of 6 players found"
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        self.lobby.addUser(withPeerID: peerID)
        let indexPath = IndexPath(row: self.lobby.count - 1, section: 0)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.lobby.getIndex(ofUser: peerID) {
            self.lobby.removeUser(withIndex: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateUI()
        }
    }
    
}

// MARK: UITableViewDataSource implementation
extension ClientLobbyVC: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lobbyCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = self.lobby.getUserNames()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: LobbyManagerDelegate implementation
extension ClientLobbyVC: ClientLobbyDelegate {
    
    func didConnectWith(peerID: MCPeerID) {
        if peerID != self.comms.hostPeerID {
            DispatchQueue.main.async {
                self.addPlayerInTableView(peerID: peerID)
            }
        }
    }
    
    func didDisconnectWith(peerID: MCPeerID) {
        if peerID == self.comms.hostPeerID {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The lobby has been closed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.comms.disconnect()
                self.present(alert, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                self.removePlayerInTableView(peerID: peerID)
            }
        }
    }
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .closeSession:
            let alert = UIAlertController(title: "Exit from lobby", message: "The host removed you from the lobby", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
                self.comms.disconnect()
            }
        case .startGame:
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showClientGameSegue", sender: nil)
            }
        default:
            print("Errore")
        }
    }
    
}
