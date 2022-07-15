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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Open Lobby
        self.serverManager.startAdvertising()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Notify the guests
        self.serverManager.disconnectSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Close lobby
        self.serverManager.stopAdvertising()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the manager
        if let vc = segue.destination as? GameViewController {
            vc.serverManager = self.serverManager
        }
    }
    
    // MARK: Actions
    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        // Notify the guests
        let message = Message(type: .startGame, text: nil, cards: nil)
        self.serverManager.sendBroadcastMessage(message)
        // Start the game
        self.performSegue(withIdentifier: "showGameSegue", sender: nil)
    }
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
        self.playersTableView.delegate = self
    }
    
    func updateUI() {
        // Label
        self.playersCounterLabel.text = "\(self.serverManager.getNumberOfPlayers()) of 6 players found"
        // Button play
        if self.serverManager.getNumberOfPlayers() > 1 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.serverManager.getNumberOfPlayers() < 2 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
    }
    
    func updateAdvertiser() {
        if self.serverManager.getNumberOfPlayers() == 6 {
            self.serverManager.stopAdvertising()
        } else {
            self.serverManager.startAdvertising()
        }
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.serverManager.getNumberOfPlayers(), section: 0)
        self.serverManager.addPlayerWith(peerID: peerID)
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
extension HostViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serverManager.getNumberOfPlayers()
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
extension HostViewController: UITableViewDelegate {
    
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
extension HostViewController: ServerManagerDelegate {
    
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

