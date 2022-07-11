//
//  ServerViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class ServerViewController: UIViewController {
    
    // MARK: Variables
    var serverManager: ServerManager!

    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.serverManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Open Lobby
        self.serverManager.startAdvertising()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Close lobby
        self.serverManager.stopAdvertising()
        self.serverManager.disconnectSession()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the data
        if let vc = segue.destination as? ServerGameViewController {
            vc.serverManager = self.serverManager
        }
    }
    
    // MARK: Actions
    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        // Notify the guests
        let message = Message(type: .startGame, text: nil, cards: nil)
        self.serverManager.sendBroadcastMessage(message)
        // Start the game
        self.performSegue(withIdentifier: "showServerGameSegue", sender: nil)
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
        self.playersTableView.delegate = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.serverManager.getNumberOrPlayers()) of 6 players found"
        // Button play
        if self.serverManager.getNumberOrPlayers() > 1 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.serverManager.getNumberOrPlayers() < 2 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
    }
    
    func updateAdvertiser() {
        if self.serverManager.getNumberOrPlayers() == 6 {
            self.serverManager.stopAdvertising()
        } else {
            self.serverManager.startAdvertising()
        }
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.serverManager.getNumberOrPlayers(), section: 0)
        self.serverManager.addPlayer(peerID: peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.updateUI()
        self.updateAdvertiser()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.serverManager.getIndexOf(player: peerID) {
            self.serverManager.removePlayerWith(index: index)
            let indexPath = IndexPath(row: index + 1, section: 0)
            self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateUI()
            self.updateAdvertiser()
        }
    }
    
}

// MARK: DataSource's delegate implementation
extension ServerViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serverManager.getNumberOrPlayers()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serverCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = Utils.convertMCPeerIDListToString(list: self.serverManager.getPlayersInLobby())[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}


// MARK: TableView's delegate implementation
extension ServerViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.serverManager.getPlayersInLobby()[indexPath.row]
        if user == self.serverManager.myPeerID {
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
                let msg = Message(type: .closeConnection, text: nil, cards: nil)
                self.serverManager.sendMessageTo(receiver: user, message: msg)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .destructive
        ))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: ServerManager's delegate implementation
extension ServerViewController: ServerManagerDelegate {
    
    func didConnectedWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.addPlayerInTableView(peerID: peerID)
        }
    }
    
    func didDisconnectedWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.removePlayerInTableView(peerID: peerID)
        }
    }
    
    func didReciveMessageFrom(sender peerID: MCPeerID, message: Data) {}
    
}

