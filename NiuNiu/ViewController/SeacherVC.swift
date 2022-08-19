//
//  SeacherVC.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import MultipeerConnectivity

class SeacherVC: UIViewController {
    
    // MARK: Properties
    var client: Client!
    var hosts: [MCPeerID]!
    var maxPlayers: Int?
    
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Supporting functions
    func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func setupTableView() {
        self.hostsTableView.dataSource = self
        self.hostsTableView.delegate = self
    }
    
    // MARK: Edit table view
    func addHostInTableView(peerID: MCPeerID) {
        self.hosts.append(peerID)
        let indexPath = IndexPath(row: self.hosts.count - 1, section: 0)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostInTableView(peerID: MCPeerID) {
        if let index = self.hosts.firstIndex(of: peerID) {
            self.hosts.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: Notification
    @objc func appMovedToBackground() {
        if Utils.getCurrentVC() is SeacherVC {
            self.client.stopBrowsing()
            self.hosts.removeAll()
            self.hostsTableView.reloadData()
        }
    }
    
    @objc func appMovedToForeground() {
        if Utils.getCurrentVC() is SeacherVC {
            self.client.startBrowsing()
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh the list of hosts
        self.hosts = [MCPeerID]()
        self.hostsTableView.reloadData()
        // Client stuffs
        self.client.searchDelegate = self
        self.client.startBrowsing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.client.stopBrowsing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Clear client's search delegate
        self.client.searchDelegate = nil
        // Setup the data for LobbyVC
        let lobbyVC = segue.destination as! LobbyVC
        lobbyVC.client = self.client
        lobbyVC.maxPlayers = self.maxPlayers
    }
    
}

// MARK: UITableViewDataSource implementation
extension SeacherVC: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hosts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.attributedText = Utils.myString(Utils.getPeersName(from: self.hosts)[indexPath.row])
        cell.contentConfiguration = content
        return cell
    }
    
}

// MARK: UITableViewDelegate implementation
extension SeacherVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.hosts[indexPath.row]
        let alert = UIAlertController(
            title: "Join in the lobby",
            message: "Do you want to join into the lobby of \(user.displayName)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { (action: UIAlertAction) in
                // Request to join in the server
                self.client.connect(to: user)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive,
            handler: { (action: UIAlertAction) in
                tableView.deselectRow(at: indexPath, animated: true)
            }
        ))
        self.present(alert, animated: true, completion: nil)
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
    
    func didHostAccept(_ peerID: MCPeerID, maxPlayers: Int) {
        self.maxPlayers = maxPlayers
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showLobbySegue", sender: nil)
        }
    }

}
