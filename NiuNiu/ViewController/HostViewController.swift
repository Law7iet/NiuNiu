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
    var myID: String!
    var myPeerID: MCPeerID!
    var mcSession: MCSession!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    
    var playersInLobby: [MCPeerID]!
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupConnectivity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addPlayerWith(peerID: self.myPeerID)
        self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.closeLobby()
        }
        self.playersInLobby.removeAll()
        self.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the data
        //        if let vc = segue.destination as? GameViewController {
//            vc.users = self.playersInLobby
//        }
    }
    
    // MARK: Actions
    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        // Start the game
        // TODO: Send a message to all players in waiting room
//        let data = Data(GameMessage(
//            type: .startGame,
//            message: nil,
//            cards: nil
//        ))
//        do {
//            try self.mcSession.send(
//                data,
//                toPeers: self.playersInLobby.list,
//                with: .reliable
//            )
//        } catch {
//            print("Data error")
//        }
    }
    
    // MARK: Supporting functions
    func setupConnectivity() {
        self.playersInLobby = [MCPeerID]()
        self.myPeerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(self.myID!)")
        
        self.mcSession = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: self.myPeerID,
            discoveryInfo: nil,
            serviceType: "niu-niu-game"
        )
        self.mcNearbyServiceAdvertiser.delegate = self
        
        self.playersTableView.delegate = self
        self.playersTableView.dataSource = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.playersInLobby.count) of 6 players found"
        // Button play
        if self.playersInLobby.count > 1 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.playersInLobby.count < 2 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
    }
    
    func updateAdvertiser() {
        if self.playersInLobby.count == 6 {
            self.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
        } else {
            self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
        }
    }
    
    func addPlayerWith(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.playersInLobby.count, section: 0)
        self.playersInLobby.append(peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
        self.updateAdvertiser()
    }
    
    func removePlayerWith(indexPath: IndexPath) {
        self.playersInLobby.remove(at: indexPath.row)
        self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
        self.updateUI()
        self.updateAdvertiser()
    }
    
    func closeLobby() {
        let message = Message(type: .closeLobby, text: nil, cards: nil)
        if let data = message.convertToData() {
            if let index = self.playersInLobby.firstIndex(of: self.myPeerID) {
                // Remove himself from the destination's peers
                self.playersInLobby.remove(at: index)
                // Send message to other devices
                try? self.mcSession.send(data, toPeers: self.playersInLobby, with: .reliable)
            }
        }
    }
}

// MARK: Multipeer Connectivity Session's delegate implementation
extension HostViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            // Add the connected player
            DispatchQueue.main.async { [self] in
                self.addPlayerWith(peerID: peerID)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            // Remove the disconnected player
            DispatchQueue.main.async { [self] in
                if let index = self.playersInLobby.firstIndex(of: peerID) {
                    self.removePlayerWith(indexPath: IndexPath(row: index, section: 0))
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
        invitationHandler(true, self.mcSession)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
    }
}

// MARK: TableView's delegate implementation
extension HostViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.playersInLobby[indexPath.row]
        if user == self.myPeerID {
            // Do nothing if clicking himself
            return
        }
        let alert = UIAlertController(
            title: "Remove user",
            message: "Do you want to remove the user " + user.displayName + "?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: {(action: UIAlertAction) in
                let msg = Message(type: .closeConnection, text: nil, cards: nil)
                if let data = msg.convertToData() {
                    try? self.mcSession.send(data, toPeers: [user], with: .reliable)
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

// MARK: DataSource's delegate implementation
extension HostViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersInLobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: self.playersInLobby)[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}
