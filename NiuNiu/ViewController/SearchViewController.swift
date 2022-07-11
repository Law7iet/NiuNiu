//
//  SeachViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class SearchViewController: UIViewController {
    
    // MARK: Variables
    var searchManager: SearchManager!
    var hostPeerID: MCPeerID!
    
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.searchManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchManager.clearHosts()
        self.hostsTableView.reloadData()
        self.searchManager.startBrowsing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searchManager.stopBrowsing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! LobbyViewController
        vc.lobbyManager = LobbyManager(
            peerID: self.searchManager.myPeerID,
            hostPeerID: self.hostPeerID,
            session: self.searchManager.session
        )
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.hostsTableView.dataSource = self
        self.hostsTableView.delegate = self
    }
    
    func addHostInTableView(peerID: MCPeerID) {
        self.searchManager.addHostWith(peerID: peerID)
        let indexPath = IndexPath(row: self.searchManager.getNumberOfHosts() - 1, section: 0)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostInTableView(peerID: MCPeerID) {
        if let index = self.searchManager.getIndexOf(host: peerID) {
            self.searchManager.removeHostWith(index: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
        }        
    }
}

// MARK: UITableViewDataSource implementation
extension SearchViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchManager.getNumberOfHosts()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: self.searchManager.hostsPeerID)[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: UITableViewDelegate implementation
extension SearchViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.searchManager.hostsPeerID[indexPath.row]
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
                self.hostPeerID = user
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

extension SearchViewController: SearchManagerDelegate {

    func didFindHostWith(peerID: MCPeerID) {
        self.addHostInTableView(peerID: peerID)
    }
    
    func didLoseHostWith(peerID: MCPeerID) {
        self.removeHostInTableView(peerID: peerID)
    }

}
