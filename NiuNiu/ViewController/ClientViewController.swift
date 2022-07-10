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
    var clientManager: ClientManager!
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clientManager.clearPlayers()
        self.playersTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.clientManager.disconnectSession()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the data
        if let vc = segue.destination as? ClientGameViewController {
            vc.users = self.clientManager.playersPeerID
            vc.mcSession = self.clientManager.mcSession
            vc.myPeerID = self.clientManager.myPeerID
            vc.hostPeerID = self.clientManager.hostPeerID
        }
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.clientManager.getNumberOfPlayers()) of 6 players found"
    }
    
    func addPlayerInTableView(mcPeerID: MCPeerID) {
        let indexPath = IndexPath(row: self.clientManager.getNumberOfPlayers(), section: 0)
        self.clientManager.addPlayer(mcPeerID: mcPeerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
    func removePlayerWith(mcPeerID: MCPeerID) {
        self.clientManager.removePlayer(mcPeerID: mcPeerID)
        let indexPath = IndexPath(row: self.clientManager.getNumberOfPlayers(), section: 0)
        self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
        self.updateUI()
    }
    
}

// MARK: UITableViewDataSource implementation
extension ClientViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clientManager.getNumberOfPlayers()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: self.clientManager.getPlayersInLobby())[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

extension ClientViewController: ClientManagerDelegate {
    
    func didConnected(who mcPeerID: MCPeerID) {
        self.addPlayerInTableView(mcPeerID: mcPeerID)
    }
    
    func didDisconnected(who mcPeerID: MCPeerID) {
        self.removePlayerWith(mcPeerID: mcPeerID)
    }
    
    func didReciveMessage(from peerID: MCPeerID, what data: Data) {
        let gameMessage = Message(data: data)
        switch gameMessage.type {
        case .closeLobby:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The lobby has been closed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.clientManager.disconnectSession()
            }
        case .closeConnection:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Exit from lobby", message: "The host removed you from the lobby", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.clientManager.disconnectSession()
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
