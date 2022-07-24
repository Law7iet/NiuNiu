//
//  ClientSeacherVC.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class SeacherVC: UIViewController {
    
    // MARK: Properties
    var client: Client!
    var lobby: [MCPeerID] = [MCPeerID]()
    
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lobby = [MCPeerID]()
        self.hostsTableView.reloadData()
        self.client.startBrowsing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.client.startBrowsing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.client.stopBrowsing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let lobbyVC = segue.destination as? LobbyVC {
            lobbyVC.client = self.client
            lobbyVC.lobby = [self.client.peerID]
        }
    }
    
    // MARK: Supporting functions
    func setupDelegates() {
        self.client.searchDelegate = self
        self.hostsTableView.dataSource = self
        self.hostsTableView.delegate = self
    }
    
    func addHostInTableView(peerID: MCPeerID) {
        self.lobby.append(peerID)
        let indexPath = IndexPath(row: self.lobby.count - 1, section: 0)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostInTableView(peerID: MCPeerID) {
        if let index = self.lobby.firstIndex(of: peerID) {
            self.lobby.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
        }        
    }
}

// MARK: UITableViewDataSource implementation
extension SeacherVC: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = Utils.getNames(fromPeerIDs: self.lobby)[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: UITableViewDelegate implementation
extension SeacherVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.lobby[indexPath.row]
        let alert = UIAlertController(
            title: "Join",
            message: "Do you want to join to \(user.displayName) lobby?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { [self] (action: UIAlertAction) in
                // Join lobby
                self.client.server = user
                self.client.connect(to: user)
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
extension SeacherVC: ClientSearchDelegate {

    func didFindHost(with: MCPeerID) {
        self.addHostInTableView(peerID: with)
    }
    
    func didLoseHost(with: MCPeerID) {
        self.removeHostInTableView(peerID: with)
    }

}
