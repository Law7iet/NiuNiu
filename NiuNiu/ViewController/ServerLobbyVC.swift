//
//  ServerLobbyVC.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class ServerLobbyVC: UIViewController {
    
    // MARK: Properties
    var comms: Server!
    var lobby: Lobby!

    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.comms.lobbyDelegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Open Lobby
        self.comms.startAdvertising()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // TODO: Check this call in this function
        // Notify the guests
        self.comms.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Close lobby
        self.comms.stopAdvertising()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the manager
        if let serverGameVC = segue.destination as? ServerGameVC {
            serverGameVC.dealer = Dealer(comms: self.comms, time: nil, points: nil)
        }
    }
    
    // MARK: Actions
    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        // Notify the guests
        self.comms.sendMessage(to: self.comms.connectedPeerIDs, message: Message(.startGame, amount: 100))
        // Close adversiting
        self.comms.stopAdvertising()
        // Start the game
        self.performSegue(withIdentifier: "showServerGameSegue", sender: nil)
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
        self.playersTableView.delegate = self
    }
    
    func updateUI() {
        // Player Counter Label
        self.playersCounterLabel.text = "\(self.lobby.count) of 6 players found"
        // Play Button
        if self.lobby.count > 1 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.lobby.count < 2 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
    }
    
    func updateAdvertiser() {
        if self.lobby.count == 6 {
            self.comms.stopAdvertising()
        } else {
            self.comms.startAdvertising()
        }
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.lobby.count, section: 0)
        self.lobby.addUser(withPeerID: peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
        self.updateAdvertiser()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.lobby.getIndex(ofUser: peerID) {
            self.lobby.removeUser(withIndex: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateUI()
            self.updateAdvertiser()
        }
    }
    
}

// MARK: UITableViewDataSource implementation
extension ServerLobbyVC: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = self.lobby.getUserNames()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}


// MARK: UITableViewDelegate implementation
extension ServerLobbyVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.lobby.users[indexPath.row]
        if user == self.comms.himselfPeerID {
            // Do nothing - The host can't kick himself
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
                let msg = Message(.closeSession)
                self.comms.sendMessage(to: [user], message: msg)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive
        ))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: HostManagerDelegate implementation
extension ServerLobbyVC: ServerLobbyDelegate {
    
    func didConnectWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.addPlayerInTableView(peerID: peerID)
        }
    }
    
    func didDisconnectWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.removePlayerInTableView(peerID: peerID)
        }
    }
    
}

