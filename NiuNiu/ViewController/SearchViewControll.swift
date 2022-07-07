//
//  JoinViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class SearchViewControll: UIViewController {
    
    // MARK: Variables
    var peerID: MCPeerID!
    var hostPeerID: MCPeerID?
    var mcNearbyServieBrowser: MCNearbyServiceBrowser!
    var mcSession: MCSession!
    
    var hosts: PeerList = PeerList()
    @IBOutlet weak var hostsTableView: UITableView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + Utils.getRandomID(length: 4)))
        self.mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        self.hostsTableView.delegate = self
        self.hostsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.mcNearbyServieBrowser = MCNearbyServiceBrowser(
            peer: self.peerID,
            serviceType: "niu-niu-game"
        )
        self.mcNearbyServieBrowser.delegate = self
        self.mcNearbyServieBrowser.startBrowsingForPeers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mcNearbyServieBrowser.stopBrowsingForPeers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! LobbyViewController
        vc.myPeerID = self.peerID
        vc.hostPeerID = self.hostPeerID
        vc.mcSession = self.mcSession
    }
    
    // MARK: Actions
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: Supporting functions
    func addHostWith(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.hosts.list.count, section: 0)
        self.hosts.list.append(peerID)
        self.hostsTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func removeHostWith(indexPath: IndexPath) {
        self.hosts.list.remove(at: indexPath.row)
        self.hostsTableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: UITableViewDelegate implementation
extension SearchViewControll: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = hosts.list[indexPath.row]
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
extension SearchViewControll: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts.list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsTableView.dequeueReusableCell(withIdentifier: "JoinCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = hosts.convertListToString()[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: MCNearbyServiceBrowserDelegate implementation
extension SearchViewControll: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.addHostWith(peerID: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = self.hosts.list.firstIndex(of: peerID) {
            let indexPath = IndexPath(row: index, section: 0)
            self.removeHostWith(indexPath: indexPath)
        }
    }
}

// MARK: MCSessionDelegate
extension SearchViewControll: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async { [self] in
                self.hostPeerID = peerID
                self.performSegue(withIdentifier: "showLobbySegue", sender: nil)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state: \(state)")
        }
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
