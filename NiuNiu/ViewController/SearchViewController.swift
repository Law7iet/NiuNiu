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
    var myID: String!
    var myPeerID: MCPeerID!
    var hostPeerID: MCPeerID!
    var mcNearbyServieBrowser: MCNearbyServiceBrowser!
    var mcSession: MCSession!
    
    var hostsAvailable: [MCPeerID]!
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostsAvailable = [MCPeerID]()
        self.myPeerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(self.myID!)")
        self.mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        self.mcNearbyServieBrowser = MCNearbyServiceBrowser(
            peer: self.myPeerID,
            serviceType: "niu-niu-game"
        )
        self.mcNearbyServieBrowser.delegate = self
        
        self.hostsTableView.delegate = self
        self.hostsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hostsAvailable.removeAll()
        self.hostsTableView.reloadData()
        self.mcNearbyServieBrowser.startBrowsingForPeers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.mcNearbyServieBrowser.stopBrowsingForPeers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ClientViewController
        vc.myPeerID = self.myPeerID
        vc.hostPeerID = self.hostPeerID
        vc.mcSession = self.mcSession
    }
    
    // MARK: Actions
    
    // MARK: Supporting functions
    func addHostWith(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.hostsAvailable.count, section: 0)
        self.hostsAvailable.append(peerID)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostWith(indexPath: IndexPath) {
        self.hostsAvailable.remove(at: indexPath.row)
        self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: UITableViewDelegate implementation
extension SearchViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = hostsAvailable[indexPath.row]
        let alert = UIAlertController(
            title: "Join",
            message: "Do you want to join to the \(user.displayName) lobby?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { [self] (action: UIAlertAction) in
                // Disconnect from the old connection
                self.mcSession.disconnect()
                // Join lobby
                self.mcNearbyServieBrowser.invitePeer(
                    user,
                    to: mcSession,
                    withContext: nil,
                    timeout: 30
                )
                self.hostPeerID = user
                self.performSegue(withIdentifier: "showClientSegue", sender: nil)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive
        ))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource implementation
extension SearchViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostsAvailable.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: hostsAvailable)[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: MCNearbyServiceBrowserDelegate implementation
extension SearchViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.addHostWith(peerID: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = self.hostsAvailable.firstIndex(of: peerID) {
            let indexPath = IndexPath(row: index, section: 0)
            self.removeHostWith(indexPath: indexPath)
        }
    }
}

// MARK: MCSessionDelegate implementation
extension SearchViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Hola from SearchViewController")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}
