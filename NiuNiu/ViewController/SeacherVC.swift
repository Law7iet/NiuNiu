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
    
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Supporting functions
    func setupTableView() {
        self.hostsTableView.dataSource = self
        self.hostsTableView.delegate = self
    }
    
    func setupClient() {
        self.client.searchDelegate = self
    }
    
    func resetHosts() {
        self.hosts = [MCPeerID]()
        self.hostsTableView.reloadData()
    }
    
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
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        print("Searcher didLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetHosts()
        self.setupClient()
        self.client.startBrowsing()
        print("SearcherVC willAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SearcherVC didAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SearcherVC willDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.client.stopBrowsing()
        print("SearcherVC didDisappear")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let lobbyVC = segue.destination as! LobbyVC
        lobbyVC.client = self.client
    }
    
    // MARK: Notification
    @objc func appMovedToBackground() {
        self.hosts.removeAll()
        self.hostsTableView.reloadData()
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
        content.text = Utils.getNames(fromPeerIDs: self.hosts)[indexPath.row]
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
        let user = self.hosts[indexPath.row]
        let alert = UIAlertController(
            title: "Join",
            message: "Do you want to join to \(user.displayName) lobby?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { [self] (action: UIAlertAction) in
                // Request to join in the server
                self.client.connect(to: user)
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
    
    func didConnectWithHost(_ peerID: MCPeerID) {
        self.client.serverPeerID = peerID
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showLobbySegue", sender: nil)
        }
    }

}
