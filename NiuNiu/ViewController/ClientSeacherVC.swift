//
//  ClientSeacherVC.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class ClientSeacherVC: UIViewController {
    
    // MARK: Properties
    var comms: Client!
    var lobby: Lobby!
    
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.comms.searchDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lobby.clearUsers(withPeers: [MCPeerID]())
        self.hostsTableView.reloadData()
        self.comms.startBrowsing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.comms.stopBrowsing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let lobbyVC = segue.destination as! ClientLobbyVC
        lobbyVC.comms = self.comms
        lobbyVC.lobby = self.lobby
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.hostsTableView.dataSource = self
        self.hostsTableView.delegate = self
    }
    
    func addHostInTableView(peerID: MCPeerID) {
        self.lobby.addUser(withPeerID: peerID)
        let indexPath = IndexPath(row: self.lobby.count - 1, section: 0)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostInTableView(peerID: MCPeerID) {
        if let index = self.lobby.getIndex(ofUser: peerID) {
            self.lobby.removeUser(withIndex: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
        }        
    }
}

// MARK: UITableViewDataSource implementation
extension ClientSeacherVC: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = self.lobby.getUserNames()[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: UITableViewDelegate implementation
extension ClientSeacherVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.lobby.users[indexPath.row]
        let alert = UIAlertController(
            title: "Join",
            message: "Do you want to join to \(user.displayName) lobby?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { [self] (action: UIAlertAction) in
                // Disconnect from the old connection if it's not disconnected yet
                self.comms.disconnect()
                // Join lobby
                self.comms.hostPeerID = user
                self.comms.connect(to: user)
                self.performSegue(withIdentifier: "showLobbySegue", sender: nil)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive
        ))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: SearchManagerDelegate implementation
extension ClientSeacherVC: ClientSearchDelegate {

    func didFindHostWith(peerID: MCPeerID) {
        self.addHostInTableView(peerID: peerID)
    }
    
    func didLoseHostWith(peerID: MCPeerID) {
        self.removeHostInTableView(peerID: peerID)
    }

}
