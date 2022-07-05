//
//  JoinViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class JoinViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    // MARK: Variables for multipeer connectivity
    var peerID: MCPeerID!
    var mcNearbyServieBrowser: MCNearbyServiceBrowser!
    var mcSession: MCSession!
    
    var hostsList = [MCPeerID]()
    @IBOutlet weak var hostsListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + Utils.getRandomID(length: 4)))
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        hostsListTableView.delegate = self
        hostsListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mcNearbyServieBrowser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: "niu-niu-game"
        )
        mcNearbyServieBrowser.delegate = self
        mcNearbyServieBrowser.startBrowsingForPeers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mcNearbyServieBrowser.stopBrowsingForPeers()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func toArrayOfString() -> [String] {
        var array = [String]()
        for element in hostsList {
            array.append(element.displayName)
        }
        return array
    }
    
    // MARK: Multipeer Connectivity Session's delegate implementation
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        switch state {
//        case MCSessionState.connected:
//            print("Connected: \(peerID.displayName)")
//        case MCSessionState.connecting:
//            print("Connecting: \(peerID.displayName)")
//        case MCSessionState.notConnected:
//            print("Not connected: \(peerID.displayName)")
//        @unknown default:
//            print("Unknown state: \(state)")
//        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Add row
        let indexPath = IndexPath(row: self.hostsList.count, section: 0)
        self.hostsList.append(peerID)
        self.hostsListTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Remove row
        if let index = self.hostsList.firstIndex(of: peerID) {
            let indexPath = IndexPath(row: index, section: 0)
            self.hostsList.remove(at: indexPath.row)
            self.hostsListTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension JoinViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available hosts"
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = hostsList[indexPath.row]
        let alert = UIAlertController(
            title: "Join",
            message: "Do you want to join to the " + user.displayName + " lobby?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { [self] (action: UIAlertAction) in
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

extension JoinViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostsList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hostsListTableView.dequeueReusableCell(withIdentifier: "JoinCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = toArrayOfString()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}
