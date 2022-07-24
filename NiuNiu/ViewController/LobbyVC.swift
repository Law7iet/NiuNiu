//
//  ServerLobbyVC.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class LobbyVC: UIViewController {
    
    // MARK: Properties
    var server: Server?
    var client: Client!
    var lobby = [MCPeerID]()

    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    // MARK: Supporting functions
    func setupDelegates() {
        self.server?.lobbyDelegate = self
        self.client.searchDelegate = self
        self.client.lobbyDelegate = self
        self.playersTableView.dataSource = self
        self.playersTableView.delegate = self
    }
    
    func update() {
        // UI
        self.playersCounterLabel.text = "\(self.lobby.count) of 6 players found"
        if self.lobby.count > 1 && !self.playButton.isEnabled {
            self.playButton.isEnabled = true
        } else if self.lobby.count < 2 && self.playButton.isEnabled {
            self.playButton.isEnabled = false
        }
        // Advertiser
        if self.lobby.count == 6 {
            self.server?.stopAdvertising()
        } else {
            self.server?.startAdvertising()
        }
    }
    
    func addPlayerInTableView(peerID: MCPeerID) {
        let indexPath = IndexPath(row: self.lobby.count, section: 0)
        self.lobby.append(peerID)
        self.playersTableView.insertRows(at: [indexPath], with: .automatic)
        self.update()
    }
    
    func removePlayerInTableView(peerID: MCPeerID) {
        if let index = self.lobby.firstIndex(of: peerID) {
            self.lobby.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.playersTableView.deleteRows(at: [indexPath], with: .automatic)
            self.update()
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDelegates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.server?.startAdvertising()
        self.client.startBrowsing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.server?.disconnect()
        self.client.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Close lobby
        self.server?.stopAdvertising()
//        self.client.stopBrowsing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Passing the manager
//        if let serverGameVC = segue.destination as? ServerGameVC {
//            serverGameVC.dealer = Dealer(server: self.server, time: nil, points: nil)
//        }
    }
    
    // MARK: Actions
    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        // Notify the guests
        self.server?.sendMessage(to: self.server!.clients, message: Message(.startGame, amount: 100))
        // Close adversiting
        self.server?.stopAdvertising()
        // Start the game
        self.performSegue(withIdentifier: "showGameSegue", sender: nil)
    }
    
}

// MARK: UITableViewDataSource implementation
extension LobbyVC: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Players in the lobby"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobby.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = Utils.getNames(fromPeerIDs: self.lobby)[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
}


// MARK: UITableViewDelegate implementation
extension LobbyVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.server != nil {
            let user = self.lobby[indexPath.row]
            if user == self.client.peerID {
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
                    self.server?.sendMessage(to: [user], message: msg)
                }
            ))
            alert.addAction(UIAlertAction(
                title: "No",
                style: .destructive
            ))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: ServerLobbyDelegate implementation
extension LobbyVC: ServerLobbyDelegate {
    
    func didServerConnect(with: MCPeerID) {
        DispatchQueue.main.async {
            self.addPlayerInTableView(peerID: with)
        }
    }
    
    func didServerDisconnect(with: MCPeerID) {
        DispatchQueue.main.async {
            self.removePlayerInTableView(peerID: with)
        }
    }
    
}

// MARK: ClientLobbyDelegate implementation
extension LobbyVC: ClientLobbyDelegate {
    
    func didConnect(with peerID: MCPeerID) {
        if self.server == nil {
            if peerID != self.client.server {
                DispatchQueue.main.async {
                    self.addPlayerInTableView(peerID: peerID)
                }
            }
        }
    }
    
    func didDisconnect(with peerID: MCPeerID) {
        if self.server == nil {
            DispatchQueue.main.async {
                self.removePlayerInTableView(peerID: peerID)
            }
//            if peerID == self.client.server {
//                // Disconnect from the other peers
//                self.client.disconnect()
//                let alert = UIAlertController(title: "Exit from lobby", message: "The lobby has been closed", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
//                    self.navigationController?.popViewController(animated: true)
//                }))
//                DispatchQueue.main.async {
//                    self.present(alert, animated: true)
//                }
//            } else {
//
//            }
        }
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        if self.server == nil {
            let message = Message(data: messageData)
            switch message.type {
            case .closeSession:
                // Disconnect from the other peers
                self.client.disconnect()
                let alert = UIAlertController(title: "Exit from lobby", message: "The host removed you from the lobby", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            case .startGame:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showGameSegue", sender: nil)
                }
            default:
                print("ClientLobbyVC.didReceiveMessage - unexpected message.type: \(message.type))")
            }
        }
    }
    
}

// MARK: Connect host's player to server
extension LobbyVC: ClientSearchDelegate {

    func didFindHost(with peerID: MCPeerID) {
        if self.server?.peerID == peerID {
            self.client.connect(to: peerID)
        }
    }
    
    func didLoseHost(with peerID: MCPeerID) {}

}
