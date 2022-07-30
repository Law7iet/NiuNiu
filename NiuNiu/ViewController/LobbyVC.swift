//
//  LobbyVC.swift
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
    var lobby: [MCPeerID]!

    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var playersCounterLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: Supporting functions
    func setupTableView() {
        self.playersTableView.dataSource = self
        self.playersTableView.delegate = self
    }
    
    func setupLobby() {
        if self.server == nil {
            self.lobby = [client.peerID]
            self.playButton.isHidden = true
        } else {
            self.lobby = [MCPeerID]()
        }
    }
    
    func setupClient() {
        self.client.lobbyDelegate = self
        self.client.searchDelegate = self
        if self.server != nil {
            self.client.serverPeerID = self.server!.peerID
        }
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
    
    func getExitAlert(withText text: String) -> UIAlertController {
        let alert = UIAlertController(title: "Exit from lobby", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
            self.client.disconnect()
            self.navigationController?.popViewController(animated: true)
        }))
        return alert
    }

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupLobby()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLobby()
        self.setupClient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.server?.startAdvertising()
        if server != nil {
            self.client.startBrowsing()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.server?.sendMessage(
            to: self.server!.clientPeerIDs,
            message: Message(.closeLobby)
        )
        self.client.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.server?.stopAdvertising()
        if server != nil {
            self.client.stopBrowsing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameVC = segue.destination as! GameVC
        if self.server != nil {
            gameVC.dealer = Dealer(server: self.server!, time: Utils.timerLong, points: Utils.points)
        }
        gameVC.client = self.client
    }
    
    // MARK: Actions
    @IBAction func play(_ sender: Any) {
        self.server?.sendMessage(
            to: self.server!.clientPeerIDs,
            message: Message(.startGame, amount: Utils.points)
        )
        // Close browsing or advertising tasks
        self.server?.stopAdvertising()
        self.client.stopBrowsing()
        self.client.lobbyDelegate = nil
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
            if user == self.server?.peerID {
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

// MARK: ClientSearchDelegate implementation
// Used by host's client
extension LobbyVC: ClientSearchDelegate {
    
    func didFindHost(with peerID: MCPeerID) {
        if peerID == self.server?.peerID {
            self.client.connect(to: peerID)
        }
    }
    
    func didLoseHost(with peerID: MCPeerID) {}
    
}

// MARK: ClientLobbyDelegate implementation
extension LobbyVC: ClientLobbyDelegate {
    
    func didConnect(with peerID: MCPeerID) {
        if (self.server == nil && peerID != self.client.serverPeerID) || self.server != nil {
            DispatchQueue.main.async {
                self.addPlayerInTableView(peerID: peerID)
            }
        }
    }
    
    func didDisconnect(with peerID: MCPeerID) {
        if peerID != self.client.serverPeerID {
            DispatchQueue.main.async {
                self.removePlayerInTableView(peerID: peerID)
            }
        }
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .startGame:
            if self.server == nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showGameSegue", sender: nil)
                }
            }
        case .closeSession:
            // Disconnect from the other peers
            self.client.disconnect()
            let alert = self.getExitAlert(withText: "The host removed you from the lobby")
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        case .closeLobby:
            let alert = self.getExitAlert(withText: "The lobby has been closed")
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        default:
            break
        }
    }

}
