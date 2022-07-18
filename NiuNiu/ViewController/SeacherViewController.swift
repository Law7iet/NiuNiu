//
//  SeachViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class SeacherViewController: UIViewController {
    
    // MARK: Properties
    var searchManager: Search!
    var searchLobby: Lobby!
    
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.searchManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchLobby.clearHosts()
        self.hostsTableView.reloadData()
        self.searchManager.startBrowsing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searchManager.stopBrowsing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let lobbyVC = segue.destination as! LobbyViewController
        lobbyVC.lobbyManager = Client(session: self.searchManager.session)
        lobbyVC.gameLobby = self.searchLobby
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.hostsTableView.dataSource = self
        self.hostsTableView.delegate = self
    }
    
    func addHostInTableView(peerID: MCPeerID) {
        self.searchLobby.addUser(withPeerID: peerID)
        let indexPath = IndexPath(row: self.searchLobby.count - 1, section: 0)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostInTableView(peerID: MCPeerID) {
        if let index = self.searchLobby.getIndex(ofPlayer: peerID) {
            self.searchLobby.removeUser(withIndex: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
        }        
    }
}

// MARK: UITableViewDataSource implementation
extension SeacherViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchLobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = self.searchLobby.getUsersName()[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: UITableViewDelegate implementation
extension SeacherViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.searchLobby.usersPeerID[indexPath.row]
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
                self.searchManager.disconnectSession()
                // Join lobby
                self.searchManager.requestToJoin(where: user)
                self.searchLobby.hostPeerID = user
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
extension SeacherViewController: SearchDelegate {

    func didFindHostWith(peerID: MCPeerID) {
        self.addHostInTableView(peerID: peerID)
    }
    
    func didLoseHostWith(peerID: MCPeerID) {
        self.removeHostInTableView(peerID: peerID)
    }

}
