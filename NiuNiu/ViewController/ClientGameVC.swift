//
//  ClientGameVC.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import MultipeerConnectivity

class ClientGameVC: UIViewController {

    // MARK: Properties
    var comms: Client!
    var himself: Player!
    var users: [User] = [User]()
    
    var bidValue = 0
    var maxBid = 0
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet var playersButton: [UIButton]!
    @IBOutlet var cardsButton: [UIButton]!
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var betSlider: UISlider!
    
    // MARK: Supporting functions
    func setTimer(time: Int) {
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.timerLabel.text = String(time - timerCounter)
            if timerCounter == time {
                timer.invalidate()
            } else {
                timerCounter += 1
            }
        }
        
    }
    
    func findUser(byName name: String) -> User? {
        for user in self.users {
            if user.name == name {
                return user
            }
        }
        return nil
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        comms.clientDelegate = self
        
        self.statusLabel.text = "The game will start soon"
        self.setTimer(time: Utils.timer5)
    }

    // MARK: Actions
    @IBAction func home(_ sender: Any) {
        let alert = UIAlertController(
            title: "Quit the game",
            message: "If you quit the game, you won't be able to play until the game ends. Are you sure to quit?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "No", style: .default)
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { action in
                self.comms.sendMessageToServer(message: Message(.closeSession))
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            })
        )
        self.present(alert, animated: true)
    }
    
    @IBAction func clickPlayer(_ sender: UIButton) {
        // Find the correct user given the 
        let user = self.findUser(byName: sender.title(for: UIControl.State.normal)!)!
        let message = "Points: \(user.points)"
        let alert = UIAlertController(
            title: user.name,
            message: message,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func bet(_ sender: Any) {
        if self.betButton.title(for: UIControl.State.normal)!.hasPrefix("Bet") {
            let bid = Int(self.betSlider.value)
            self.pointsLabel.text = "Points: \(String(self.himself.points - bid)) (\(bid))"
            self.himself.bid = bid
            self.comms.sendMessageToServer(message: Message(.bet, users: [self.himself.convertToUser()]))
        } else {
            self.betButton.isEnabled = false
            if self.betButton.title(for: UIControl.State.normal) == "Check" {
                self.pointsLabel.text = "Points: \(String(self.himself.points - self.maxBid)) (\(self.maxBid))"
                self.himself.bid = self.maxBid
                self.comms.sendMessageToServer(message: Message(.check, users: [self.himself.convertToUser()]))
            }
            if self.betButton.title(for: UIControl.State.normal) == "All-in" {
                self.pointsLabel.text = "Points: 0"
                self.himself.bid = self.himself.points
                self.himself.status = .allIn
                self.comms.sendMessageToServer(message: Message(.check, users: [self.himself.convertToUser()]))
            }
        }
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        // UI
        if let index = self.cardsButton.firstIndex(of: sender) {
            if self.clickedButtons[index] == false {
                self.clickedButtons[index] = true
                sender.layer.cornerRadius = Utils.cornerRadius
                sender.layer.borderWidth = Utils.borderWidth
                sender.layer.borderColor = UIColor.red.cgColor
            } else {
                self.clickedButtons[index] = false
                sender.layer.borderWidth = 0
            }
        }
    }

    @IBAction func pickCards(_ sender: Any) {
        
    }
    
    @IBAction func fold(_ sender: Any) {
    
    }

    @IBAction func changeSliderValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.bidValue = currentValue
        let buttonTitle = self.betButton.title(for: UIControl.State.normal)
        if buttonTitle != "Check" || buttonTitle != "All-in" {
            self.betButton.setTitle("Bet (\(currentValue))", for: UIControl.State.normal)
        }
    }
    
}

// MARK: LobbyManagerDelegate implementation
extension ClientGameVC: ClientDelegate {
    
    func didConnectWith(peerID: MCPeerID) {}
    
    func didDisconnectWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Exit from game", message: "The game has been closed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            }))
            self.comms.disconnect()
            self.present(alert, animated: true)
        }
    }
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .startMatch:
            DispatchQueue.main.async {
                self.statusLabel.text = "Match started!"
                self.users = message.users!
                var index = 0
                for user in self.users {
                    if user.name == self.comms.himselfPeerID.displayName {
                        // Setup himself cards
                        self.himself = user.convertToPlayer(withPeerID: self.comms.himselfPeerID)
                        for cardIndex in 0 ... 4 {
                            let image = UIImage(named: self.himself.cards!.elements[cardIndex].getName())
                            self.cardsButton[cardIndex].setBackgroundImage(image, for: UIControl.State.normal)
                        }
                        // Setup himself labels
                        self.userLabel.text = self.himself.id.displayName
                        self.pointsLabel.text = "Points: \(self.himself.points)"
                        self.betSlider.minimumValue = 0.0
                        self.betSlider.maximumValue = Float(self.himself.points)
                    } else {
                        // Setup the other players
                        self.playersButton[index].setTitle(self.users[index].name, for: UIControl.State.normal)
                        self.playersButton[index].isEnabled = true
                        index += 1
                    }
                }
            }
        case .startBet:
            DispatchQueue.main.async {
                self.statusLabel.text = "Start Bet!"
                self.betSlider.isEnabled = true
                self.betButton.isEnabled = true
                self.foldButton.isEnabled = true
                self.setTimer(time: 30)
            }
        case .stopBet:
            DispatchQueue.main.async {
                self.statusLabel.text = "Stop Bet!"
                self.betSlider.isEnabled = false
                self.betButton.isEnabled = false
                self.foldButton.isEnabled = false
                // Set points
                self.himself.points = self.himself.points - self.himself.bid
                self.pointsLabel.text = String(self.himself.points)
            }
            
        case .startCheck:
            DispatchQueue.main.async {
                self.statusLabel.text = "Start Check!"
                self.maxBid = message.amount!
                if self.himself.bid != self.maxBid {
                    let diff = self.maxBid - self.himself.bid
                    if diff > 0 {
                        // Setup bet button and labels
                        self.betButton.setTitle("Check (+\(diff))", for: UIControl.State.normal)
                        self.betButton.isEnabled = true
                        self.foldButton.isEnabled = true
                    } else {
                        // The user doens't have enough points
                        // He can "all-in" or "fold"
                        self.betButton.setTitle("All-in", for: UIControl.State.normal)
                        self.betButton.isEnabled = true
                        self.foldButton.isEnabled = true
                    }
                }
                self.setTimer(time: 30)
            }
        case .stopCheck:
            self.betButton.isEnabled = false
            self.foldButton.isEnabled = false
            
            // Set points
            self.himself.points = self.himself.points - self.himself.bid
            self.pointsLabel.text = String(self.himself.points)

        case .startCards:
            print("startCards")
        case .stopCards:
            print("endCards")
        case .endMatch:
            print("endMatch")
        case .endGame:
            print("endGame")
        
        // TODO: check if there're closeConnection or closeLobby
        default:
            print("ClientGameVC.didReceiveMessageFrom - message.type == \(message.type)")
        }
    }
    
}
