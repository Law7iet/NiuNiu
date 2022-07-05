//
//  HostViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    // MARK: Variables for multipeer connectivity
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    
    var waitingPlayers: [String] = [String]()
    @IBOutlet weak var waitingPlayersTableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + Utils.getRandomID(length: 4)))
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: "niu-niu-game"
        )
        mcNearbyServiceAdvertiser.delegate = self
        mcNearbyServiceAdvertiser.startAdvertisingPeer()
        
        waitingPlayersTableView.delegate = self
        waitingPlayersTableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mcNearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        dismiss(animated: true)
        // Start the game
    }
    
    // MARK: Multipeer Connectivity Session's delegate implementation
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async { [self] in
                let indexPath = IndexPath(row: self.waitingPlayers.count, section: 0)
                self.waitingPlayers.append(peerID.displayName)
                self.waitingPlayersTableView.insertRows(at: [indexPath], with: .automatic)
                if self.waitingPlayers.count > 0 && !self.playButton.isEnabled {
                    self.playButton.isEnabled = true
                }
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            DispatchQueue.main.async { [self] in
                if let index = self.waitingPlayers.firstIndex(of: peerID.displayName) {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.waitingPlayers.remove(at: index)
                    self.waitingPlayersTableView.deleteRows(at: [indexPath], with: .automatic)
                    if self.waitingPlayers.count == 0 && self.playButton.isEnabled {
                        self.playButton.isEnabled = false
                    }
                }
            }
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
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Connessione")
        invitationHandler(true, self.mcSession)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Help")
    }
    
}

extension HostViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = waitingPlayers[indexPath.row]
        let alert = UIAlertController(
            title: "Remove user",
            message: "Are you sure to remove the user " + user + "?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { (action: UIAlertAction) in
                // Remove
                self.waitingPlayers.remove(at: indexPath.row)
                self.waitingPlayersTableView.deleteRows(at: [indexPath], with: .automatic)
                if self.waitingPlayers.count == 0 && self.playButton.isEnabled {
                    self.playButton.isEnabled = false
                }
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive
        ))
        present(alert, animated: true, completion: nil)
    }
}

extension HostViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waitingPlayers.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = waitingPlayersTableView.dequeueReusableCell(withIdentifier: "HostCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = waitingPlayers[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}
