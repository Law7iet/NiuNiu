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
    var lobbyManager: LobbyManager!
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        lobbyManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lobbyManager.clearPlayersInLobby()
        self.playersTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.lobbyManager.disconnectSession()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the data
        if let vc = segue.destination as? ClientGameViewController {
            vc.users = self.lobbyManager.playersPeerID
            vc.mcSession = self.lobbyManager.session
            vc.myPeerID = self.lobbyManager.myPeerID
            vc.hostPeerID = self.lobbyManager.hostPeerID
        }
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.lobbyManager.getNumberOfPlayers()) of 6 players found"
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        self.lobbyManager.addPlayerWith(peerID: peerID)
        let indexPath = IndexPath(row: self.lobbyManager.getNumberOfPlayers() - 1, section: 0)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.lobbyManager.getIndexOf(player: peerID) {
            self.lobbyManager.removePlayerWith(index: index)
            let indexPath = IndexPath(row: index + 1, section: 0)
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
        return self.lobbyManager.getNumberOfPlayers()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lobbyCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: self.lobbyManager.getPlayersInLobby())[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

extension LobbyViewController: LobbyManagerDelegate {
    
    func didConnectWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.addPlayerInTableView(peerID: peerID)
        }
    }
    
    func didDisconnectWith(peerID: MCPeerID) {
        if peerID == self.lobbyManager.hostPeerID {
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
        case .testMessage:
            print("Ack")
        default:
            print("Errore")
        }
    }
    
}
