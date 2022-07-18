//
//  HostViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController {
    
    // MARK: Properties
    var hostManager: Server!
    var gameLobby: Lobby!

    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.hostManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Open Lobby
        self.hostManager.startAdvertising()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Notify the guests
        self.hostManager.disconnectSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Close lobby
        self.hostManager.stopAdvertising()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the manager
        if let serverGameVC = segue.destination as? ServerGameViewController {
            serverGameVC.dealer = Dealer(serverManager: self.hostManager, lobby: self.gameLobby, time: nil, points: nil)
            serverGameVC.myPeerID = self.gameLobby.myPeerID
            serverGameVC.serverPeerID = self.gameLobby.hostPeerID
        }
    }
    
    // MARK: Actions
    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        // Notify the guests
        self.hostManager.sendMessageTo(self.gameLobby.getSendablePeersID(), message: Message(.startGame))
        // Close adversiting
        self.hostManager.stopAdvertising()
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
        self.playersCounterLabel.text = "\(self.gameLobby.count) of 6 players found"
        // Play Button
        if self.gameLobby.count > 1 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.gameLobby.count < 2 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
    }
    
    func updateAdvertiser() {
        if self.gameLobby.count == 6 {
            self.hostManager.stopAdvertising()
        } else {
            self.hostManager.startAdvertising()
        }
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.gameLobby.count, section: 0)
        self.gameLobby.addUser(withPeerID: peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
        self.updateAdvertiser()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.gameLobby.getIndex(ofPlayer: peerID) {
            self.gameLobby.removeUser(withIndex: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateUI()
            self.updateAdvertiser()
        }
    }
    
}

// MARK: UITableViewDataSource implementation
extension HostViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameLobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = self.gameLobby.getUsersName()[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}


// MARK: UITableViewDelegate implementation
extension HostViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.gameLobby.usersPeerID[indexPath.row]
        if user == self.gameLobby.myPeerID {
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
                let msg = Message(.closeConnection)
                self.hostManager.sendMessageTo([user], message: msg)
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
extension HostViewController: ServerDelegate {
    
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
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData data: Data) {}
    
}

