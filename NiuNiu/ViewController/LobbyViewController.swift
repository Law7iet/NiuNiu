//
//  LobbyViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

import UIKit
import MultipeerConnectivity

class LobbyViewController: UIViewController {

    // MARK: Properties
    var lobbyManager: Client!
    var gameLobby: Lobby!
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        lobbyManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.gameLobby.clearPlayers()
        self.playersTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.lobbyManager.disconnectSession()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the manager
        if let clientVC = segue.destination as? ClientGameViewController {
            clientVC.clientManager = self.lobbyManager
            clientVC.myPeerID = self.gameLobby.myPeerID
            clientVC.serverPeerID = self.gameLobby.hostPeerID
        }
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.gameLobby.count) of 6 players found"
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        self.gameLobby.addUser(withPeerID: peerID)
        let indexPath = IndexPath(row: self.gameLobby.count - 1, section: 0)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.gameLobby.getIndex(ofPlayer: peerID) {
            self.gameLobby.removeUser(withIndex: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateUI()
        }
    }
    
}

// MARK: UITableViewDataSource implementation
extension LobbyViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameLobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lobbyCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = self.gameLobby.getUsersName()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: LobbyManagerDelegate implementation
extension LobbyViewController: ClientDelegate {
    
    func didConnectWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.addPlayerInTableView(peerID: peerID)
        }
    }
    
    func didDisconnectWith(peerID: MCPeerID) {
        if peerID == self.gameLobby.hostPeerID {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The lobby has been closed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.lobbyManager.disconnectSession()
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
        case .closeConnection:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The host removed you from the lobby", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.lobbyManager.disconnectSession()
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
