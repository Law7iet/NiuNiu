//
//  GameVC.swift
//  NiuNiu
//
//  Created by Han Chu on 24/07/22.
//

import MultipeerConnectivity

class GameVC: UIViewController {

    // MARK: Properties
    var dealer: Dealer?
    
    var client: Client!
    var player: Player!
    var users: [User]!
    
    var maxBid = 0
    var totalBid = 0
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var foldLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var playersButton: [UIButton]!
    @IBOutlet var cardsButton: [UIButton]!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var betSlider: UISlider!
    
    // MARK: Supporting functions
    func setupMenu() {
        let quitAction = UIAction(title: "Quit", image: UIImage(systemName: "rectangle.portrait.and.arrow.right")) { (action) in
            let message = self.dealer != nil ? "If you quit the game, the game will end. Are you sure to quit?" : "If you quit the game, you won't be able to play until the game ends. Are you sure to quit?"
            let alert = UIAlertController(
                title: "Quit the game",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "No",
                style: .default)
            )
            alert.addAction(UIAlertAction(
                title: "Yes",
                style: .destructive,
                handler: { action in
                    // Notify and exit or close
                    if self.dealer != nil {
                        self.dealer?.server.sendMessage(to: self.dealer!.server.clientsPeerIDs, message: Message(.closeLobby))
                    } else {
                        self.client.sendMessageToServer(message: Message(.closeSession))
                    }
                    self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
                }
            ))
            self.present(alert, animated: true)
        }
        let menu = UIMenu(title: "Menu", options: .displayInline, children: [quitAction])
        menuButton.menu = menu
    }
    
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
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMenu()
        self.client.gameDelegate = self
        self.statusLabel.text = "The game will start soon"
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.timerLabel.text = String(Utils.timerShort - timerCounter)
            if timerCounter == Utils.timerShort {
                timer.invalidate()
                // Start the game
                if self.dealer != nil {
                    self.dealer!.play()
                }
            } else {
                timerCounter += 1
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let endVC = segue.destination as! EndVC
        if self.dealer != nil {
            endVC.dealer = self.dealer!
        }
        endVC.client = self.client
        endVC.users = self.users
        endVC.prize = self.totalBid
    }
    
    // MARK: Actions
    @IBAction func clickPlayer(_ sender: UIButton) {
//        let player = Utils.findPlayer(byName: sender.currentTitle!, from: self.dealer.players.elements)!
//        let alert = UIAlertController(
//            title: player.id.displayName,
//            message: "Points: \(player.points)",
//            preferredStyle: UIAlertController.Style.actionSheet
//        )
//        alert.addAction(UIAlertAction(title: "Close", style: .default))
//        self.present(alert, animated: true)
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        // Animation of the card
        if let index = self.cardsButton.firstIndex(of: sender) {
            self.player.cards!.pickCardAt(index: index)
            if self.clickedButtons[index] == false {
                self.clickedButtons[index] = true
                sender.layer.cornerRadius = Utils.cornerRadius
                sender.layer.borderWidth = Utils.borderWidth(withHeight: self.cardsButton[0].frame.height)
                sender.layer.borderColor = UIColor.red.cgColor
            } else {
                self.clickedButtons[index] = false
                sender.layer.borderWidth = 0
            }
        }
        // Enable or disable action button
        if self.player.status == .cards {
            if self.player.cards!.numberOfPickedCards == 1 || self.player.cards!.numberOfPickedCards == 3 {
                self.actionButton.isEnabled = true
            } else {
                self.actionButton.isEnabled = false
            }
        }
    }

    @IBAction func clickAction(_ sender: Any) {
        self.actionButton.isEnabled = false
        self.foldButton.isEnabled = false
        self.betSlider.isEnabled = false
        
        switch self.player.status {
        case .bet:
            let bid = Int(self.betSlider.value)
            self.player.bid = bid
            self.player.points = self.player.points - bid
            self.pointsLabel.text = "Points: \(String(self.player.points)) (\(bid))"
            self.client.sendMessageToServer(
                message: Message(.bet, users: [self.player.convertToUser()])
            )
        case .check:
            let diff = self.maxBid - self.player.bid
            self.player.bid = diff
            self.player.points = self.player.points - diff
            self.pointsLabel.text = "Points: \(String(self.player.points)) (\(self.maxBid))"
            self.client.sendMessageToServer(
                message: Message(.check, users: [self.player.convertToUser()])
            )
        case .allIn:
            self.player.bid += self.player.points
            self.player.points = 0
            self.pointsLabel.text = "Points: 0"
            self.client.sendMessageToServer(
                message: Message(.check, users: [self.player.convertToUser()])
            )
        case .cards:
            // TODO: Lock the cards
            self.client.sendMessageToServer(
                message: Message(.cards, users: [self.player.convertToUser()])
            )
        default:
            break
        }
    }
    
    @IBAction func fold(_ sender: Any) {
        self.foldButton.isEnabled = false
        self.actionButton.isEnabled = false
        self.betSlider.isEnabled = false
        
        self.foldLabel.isHidden = false
        self.foldLabel.layer.cornerRadius = Utils.cornerRadius
        self.player.status = .fold
        self.client.sendMessageToServer(
            message: Message(.fold, users: [self.player.convertToUser()])
        )
    }
    
    @IBAction func changeSliderValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        if self.player.status == .bet {
            self.actionButton.setTitle("Bet (\(currentValue))", for: UIControl.State.normal)
        }
    }
    
}

extension GameVC: ClientGameDelegate {
    
    // MARK: Supporting fuctions
    func setupPlayers() {
        var index = 0
        for user in self.users {
            if user.name == self.client.peerID.displayName {
                // Setup himself cards
                self.player = user.convertToPlayer(withPeerID: self.client.peerID)
                for cardIndex in 0 ... 4 {
                    let image = UIImage(named: self.player.cards!.elements[cardIndex].getName())
                    self.cardsButton[cardIndex].setBackgroundImage(image, for: UIControl.State.normal)
                }
                // Setup himself labels
                self.userLabel.text = self.player.id.displayName
                self.pointsLabel.text = "Points: \(self.player.points)"
                self.betSlider.minimumValue = 0.0
                self.betSlider.maximumValue = Float(self.player.points)
            } else {
                // Setup the other players
                self.playersButton[index].setTitle(self.users[index].name, for: UIControl.State.normal)
                self.playersButton[index].isEnabled = true
                index += 1
            }
        }
    }
    
    func didDisconnect(with peerID: MCPeerID) {}
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        // MARK: StartMatch
        case .startMatch:
            DispatchQueue.main.async {
                self.statusLabel.text = "Match started!"
                self.users = message.users!
                self.setupPlayers()
                for btn in self.cardsButton {
                    btn.isEnabled = true
                }
            }
        // MARK: StartBet
        case .startBet:
            DispatchQueue.main.async {
                // TODO: All players that receive .startBet shouldn't have .fold as status
                if self.player.status != .fold {

                    self.player.status = .bet
                    self.statusLabel.text = "Start Bet!"

                    self.actionButton.setTitle("Bet (0)", for: UIControl.State.normal)
                    self.actionButton.isEnabled = true
                    self.foldButton.isEnabled = true
                    self.betSlider.isEnabled = true
                    
                    self.setTimer(time: Utils.timerLong)
                }
            }
        // MARK: StopBet
        case .stopBet:
            DispatchQueue.main.async {
                // TODO: All players that receive .stopBet shouldn't have .fold as status
                if self.player.status != .fold {
                    
                    self.player.status = .none
                    self.statusLabel.text = "Stop Bet!"
                    
                    self.actionButton.isEnabled = false
                    self.foldButton.isEnabled = false
                    self.betSlider.isEnabled = false
                }
            }
        // MARK: StartCheck
        case .startCheck:
            DispatchQueue.main.async {
                // TODO: All players that receive .startCheck shouldn't have .fold as status
                if self.player.status != .fold {
                    
                    self.statusLabel.text = "Start Check!"
                    self.maxBid = message.amount!
                    
                    if self.player.bid != self.maxBid {
                        let diff = self.maxBid - self.player.bid
                        if diff < self.player.points {
                            // Setup bet button and labels
                            self.player.status = .check
                            self.actionButton.setTitle("Check +\(diff)", for: UIControl.State.normal)
                            self.actionButton.isEnabled = true
                            self.foldButton.isEnabled = true
                        } else {
                            // The user doens't have enough points
                            self.player.status = .allIn
                            self.actionButton.setTitle("All-in", for: UIControl.State.normal)
                            self.actionButton.isEnabled = true
                            self.foldButton.isEnabled = true
                        }
                    }
                    
                    self.setTimer(time: Utils.timerLong)
                }
                
            }
        // MARK: StopCheck
        case .stopCheck:
            DispatchQueue.main.async {
                // TODO: All players that receive .stopCheck shouldn't have .fold as status
                if self.player.status != .fold {
                    
                    self.player.status = .none
                    self.statusLabel.text = "Stop Check!"
                    
                    self.actionButton.isEnabled = false
                    self.foldButton.isEnabled = false
                }
            }
        // MARK: StartCards
        case .startCards:
            DispatchQueue.main.async {
                // TODO: All players that receive .stopBet shouldn't have .fold as status
                if self.player.status != .fold {
                    
                    self.player.status = .cards
                    self.statusLabel.text = "Start pick cards!"
    
                    self.actionButton.isEnabled = true
                    self.actionButton.setTitle("Pick cards", for: UIControl.State.normal)
                    
                    self.setTimer(time: Utils.timerLong)
                }
            }
        // MARK: StopCards
        case .stopCards:
            DispatchQueue.main.async {
                self.statusLabel.text = "Stop cards!"
                // TODO: All players that receive .stopBet shouldn't have .fold as status
                if self.player.status != .fold {
                 
                    self.player.status = .none
                    self.statusLabel.text = "Stop Cards!"
                }
            }
        // MARK: EndMatch
        case .endMatch:
            DispatchQueue.main.async {
                self.totalBid = message.amount!
                self.users = message.users!
                self.performSegue(withIdentifier: "showEndSegue", sender: nil)
            }
        case .endGame:
            print("endGame")
        
        // TODO: check if there're closeConnection or closeLobby
        default:
            print("ClientGameVC.didReceiveMessageFrom - message.type == \(message.type)")
        }
    }
    
}
