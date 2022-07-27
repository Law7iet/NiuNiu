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
    var timer: Timer?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var foldLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var usersButton: [UIButton]!
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
                self.playerLabel.text = self.player.id.displayName
                self.pointsLabel.text = "Points: \(self.player.points)"
                self.betSlider.minimumValue = 0.0
                self.betSlider.maximumValue = Float(self.player.points)
            } else {
                // Setup the other players
                self.usersButton[index].setTitle(user.name, for: UIControl.State.normal)
                self.usersButton[index].isEnabled = true
                self.usersButton[index].isHidden = false
                index += 1
            }
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMenu()
        self.client.gameDelegate = self
        
        self.dealer?.play()
        // Hide UI
        for userButton in self.usersButton {
            userButton.isHidden = true
        }
        for playerCard in self.cardsButton {
            playerCard.isHidden = true
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let endVC = segue.destination as? EndVC {
            endVC.dealer = self.dealer
            endVC.client = self.client
            endVC.users = self.users
            endVC.prize = self.totalBid
        }
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
            self.actionButton.setTitle("Cards picked", for: UIControl.State.normal)
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
    
    @IBAction func unwindToGameVC(segue: UIStoryboardSegue) {}
}

extension GameVC: ClientGameDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {}
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        // MARK: StartMatch
        case .startMatch:
            DispatchQueue.main.async {
                self.statusLabel.text = "The game will start soon"
                self.timerLabel.text = String(Utils.timerShort)
                self.users = message.users!
                self.setupPlayers()
                var timerCounter = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerShort - timerCounter)
                    if timerCounter == Utils.timerShort {
                        timer.invalidate()
                        self.statusLabel.text = "Match started!"
                        self.timerLabel.text = ""
                        
                        for btn in self.cardsButton {
                            btn.isEnabled = true
                            btn.isHidden = false
                        }
                    }
                }
            }
        // MARK: StartBet
        case .startBet:
            DispatchQueue.main.async {
                self.player.status = .bet
                self.statusLabel.text = "Start Bet!"
                self.timerLabel.text = String(Utils.timerLong)
                self.actionButton.setTitle("Bet (0)", for: UIControl.State.normal)
                self.actionButton.isEnabled = true
                self.foldButton.isEnabled = true
                self.betSlider.isEnabled = true
                
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerLong - timerCounter)
                    if timerCounter == Utils.timerLong {
                        timer.invalidate()
                        self.player.status = .none
                        self.statusLabel.text = "Stop Bet!"
                        self.timerLabel.text = ""
                        self.actionButton.isEnabled = false
                        self.foldButton.isEnabled = false
                        self.betSlider.isEnabled = false
                    }
                }
            }
        // MARK: StopBet
        case .stopBet:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.player.status = .none
                self.statusLabel.text = "Stop Bet!"
                self.timerLabel.text = ""
                self.actionButton.isEnabled = false
                self.foldButton.isEnabled = false
                self.betSlider.isEnabled = false
            }
        // MARK: StartCheck
        case .startCheck:
            DispatchQueue.main.async {
                self.statusLabel.text = "Start Check!"
                self.timerLabel.text = String(Utils.timerLong)
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
                
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerLong - timerCounter)
                    if timerCounter == Utils.timerLong {
                        timer.invalidate()
                        self.statusLabel.text = "Stop Check!"
                        self.timerLabel.text = ""
                        self.actionButton.isEnabled = false
                        self.foldButton.isEnabled = false
                    }
                }
            }
        // MARK: StopCheck
        case .stopCheck:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.player.status = .none
                self.statusLabel.text = "Stop Check!"
                self.timerLabel.text = ""
                self.actionButton.isEnabled = false
                self.foldButton.isEnabled = false
            }
        // MARK: StartCards
        case .startCards:
            DispatchQueue.main.async {
                self.player.status = .cards
                self.statusLabel.text = "Start pick cards!"
                self.timerLabel.text = String(Utils.timerLong)
                self.actionButton.isEnabled = true
                self.actionButton.setTitle("Pick cards", for: UIControl.State.normal)
                    
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerLong - timerCounter)
                    if timerCounter == Utils.timerLong {
                        timer.invalidate()
                        self.player.status = .none
                        self.statusLabel.text = "Stop Cards!"
                        self.timerLabel.text = ""
                    }
                }
            }
        // MARK: StopCards
        case .stopCards:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.player.status = .none
                self.statusLabel.text = "Stop Cards!"
                self.timerLabel.text = ""
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
