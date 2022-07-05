//
//  HostViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController {
    
    // MARK: Variables
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    
    var playersInLobby: PeerList = PeerList()
    @IBOutlet weak var playersTableView: UITableView!
    
    @IBOutlet weak var playButton: UIButton!

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + Utils.getRandomID(length: 4)))
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: self.peerID,
            discoveryInfo: nil,
            serviceType: "niu-niu-game"
        )
        self.mcNearbyServiceAdvertiser.delegate = self
        self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
        
        self.playersTableView.delegate = self
        self.playersTableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    // MARK: Actions
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        dismiss(animated: true)
        // Start the game
    }
    
    // MARK: Supporting functions
    func updatePlayButton() {
        if self.playersInLobby.list.count > 0 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.playersInLobby.list.count == 0 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
    }
    
    func addPlayerWith(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.playersInLobby.list.count, section: 0)
        self.playersInLobby.list.append(peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updatePlayButton()
    }
    
    func removePlayerWith(indexPath: IndexPath) {
        self.playersInLobby.list.remove(at: indexPath.row)
        self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
        self.updatePlayButton()
    }
}

// MARK: Multipeer Connectivity Session's delegate implementation
extension HostViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async { [self] in
                self.addPlayerWith(peerID: peerID)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            DispatchQueue.main.async { [self] in
                if let index = self.playersInLobby.list.firstIndex(of: peerID) {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.removePlayerWith(indexPath: indexPath)
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
}

// MARK: Multipeer Connectivity Advertiser's delegate implementation
extension HostViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Connecting")
        invitationHandler(true, self.mcSession)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Help")
    }
}

// MARK: TableView's delegate implementation
extension HostViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.playersInLobby.list[indexPath.row]
        let alert = UIAlertController(
            title: "Remove user",
            message: "Are you sure to remove the user " + user.displayName + "?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { (action: UIAlertAction) in
                self.removePlayerWith(indexPath: indexPath)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive
        ))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: DataSource's delegate implementation
extension HostViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersInLobby.list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = self.playersInLobby.convertListToString()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}
