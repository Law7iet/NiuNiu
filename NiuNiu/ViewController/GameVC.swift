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
    var players: [Player]!
    
    var maxBid = 0
    var totalBid = 0
    var isClicked = false
    var clickedButtons = [false, false, false, false, false]
    var timer: Timer?
    var userData: UIAlertController?
    var userDataSpinner: UIActivityIndicatorView?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var foldLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var playersButtons: [UIButton]!
    @IBOutlet var cardsButtons: [UIButton]!
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
                    self.dealer?.server.disconnect()
                    self.client.disconnect()
                    self.performSegue(withIdentifier: "backToMainSegue", sender: self)
                }
            ))
            self.present(alert, animated: true)
        }
        let menu = UIMenu(title: "Menu", options: .displayInline, children: [quitAction])
        menuButton.menu = menu
    }
    
    func setupPlayers() {
        var index = 0
        for player in self.players {
            if player.id == self.client.peerID.displayName {
                // Setup himself cards
                self.player = player
                for cardIndex in 0 ... 4 {
                    let image = UIImage(named: self.player.cards[cardIndex].fileName)
                    self.cardsButtons[cardIndex].setBackgroundImage(image, for: UIControl.State.normal)
                    self.cardsButtons[cardIndex].setBackgroundImage(image, for: UIControl.State.disabled)
                }
                // Setup himself labels
                self.playerLabel.text = self.player.id
                self.pointsLabel.text = "Points: \(self.player.points)"
                self.betSlider.minimumValue = 0.0
                self.betSlider.maximumValue = Float(self.player.points)
            } else {
                // Setup the other players
                self.playersButtons[index].setTitle(player.id, for: UIControl.State.normal)
                self.playersButtons[index].isEnabled = true
                index += 1
            }
        }
    }
    
    func setupUserButton(withSlider flag: Bool, turnOn: Bool) {
        if turnOn {
            self.actionButton.isEnabled = true
            self.foldButton.isEnabled = true
            if flag {
                self.betSlider.isEnabled = flag == true
            }
        } else {
            self.actionButton.isEnabled = false
            self.foldButton.isEnabled = false
            if flag {
                self.betSlider.isEnabled = false
            }
        }
    }
    
    func checkPickedCards() {
        if self.player.status == .cards {
            if self.player.numberOfPickedCards == 1 || self.player.numberOfPickedCards == 3 {
                self.actionButton.isEnabled = true
            } else {
                self.actionButton.isEnabled = false
            }
        }
    }
    
    func fold() {
        // Disable buttons
        self.setupUserButton(withSlider: true, turnOn: false)
        for btn in self.cardsButtons {
            btn.isEnabled = false
        }
        // Show/hide views
        self.foldLabel.layer.cornerRadius = Utils.cornerRadius
        self.foldLabel.isHidden = false
        // Change data
        self.player.status = .fold
        self.client.sendMessageToServer(
            message: Message(.fold, players: [self.player])
        )
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        print("GameVC didLoad")
        super.viewDidLoad()
        self.setupMenu()
        self.client.gameDelegate = self
        
        self.dealer?.play()
        
        // Hide UI
        for btn in self.playersButtons + self.cardsButtons {
            btn.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("GameVC willAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("GameVC didAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("GameVC willDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("GameVC didDisappear")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let endVC = segue.destination as? EndVC {
            endVC.dealer = self.dealer
            endVC.client = self.client
            endVC.players = self.players
            endVC.prize = self.totalBid
        }
    }
    
    // MARK: Actions
    @IBAction func clickPlayer(_ sender: UIButton) {
        let player = Utils.findPlayer(byName: sender.currentTitle!, from: self.players)!
        self.userData = UIAlertController(
            title: player.id,
            message: "Fetching data...\n\n",
            preferredStyle: .actionSheet
        )
        self.self.userData!.addAction(UIAlertAction(title: "Close", style: .default))
        
        self.userDataSpinner = UIActivityIndicatorView(
            frame: CGRect(x: UIScreen.main.bounds.width / 2 - 30, y: 60, width: 40, height: 40)
        )
        self.userDataSpinner!.startAnimating();
        self.userData!.view.addSubview(self.userDataSpinner!)

        self.present(self.self.userData!, animated: true, completion: nil)
        
        self.client.sendMessageToServer(
            message: Message(.reqPlayer, players: [player])
        )
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        // Animation of the card
        if let index = self.cardsButtons.firstIndex(of: sender) {
            self.player.pickCard(atIndex: index)
            if self.clickedButtons[index] == false {
                self.clickedButtons[index] = true
                sender.layer.cornerRadius = Utils.cornerRadius
                sender.layer.borderWidth = Utils.borderWidth(withHeight: self.cardsButtons[0].frame.height)
                sender.layer.borderColor = UIColor.red.cgColor
            } else {
                self.clickedButtons[index] = false
                sender.layer.borderWidth = 0
            }
        }
        // Enable or disable action button
        self.checkPickedCards()
    }

    @IBAction func clickAction(_ sender: Any) {
        
        self.isClicked = true
        self.setupUserButton(withSlider: true, turnOn: false)
        
        switch self.player.status {
        case .bet:
            let bid = Int(self.betSlider.value)
            if bid == 0 {
                self.fold()
            } else {
                self.player.bid = bid
                self.player.points = self.player.points - bid
                self.pointsLabel.text = "Points: \(String(self.player.points)) (\(bid))"
                self.client.sendMessageToServer(
                    message: Message(.bet, players: [self.player])
                )
            }
        case .check:
            let diff = self.maxBid - self.player.bid
            self.player.bid = diff
            self.player.points = self.player.points - diff
            self.pointsLabel.text = "Points: \(String(self.player.points)) (\(self.maxBid))"
            self.client.sendMessageToServer(
                message: Message(.check, players: [self.player])
            )
        case .allIn:
            self.player.bid += self.player.points
            self.player.points = 0
            self.pointsLabel.text = "Points: 0"
            self.client.sendMessageToServer(
                message: Message(.check, players: [self.player])
            )
        case .cards:
            self.actionButton.setTitle("Cards picked", for: UIControl.State.normal)
            for btn in self.cardsButtons {
                btn.isEnabled = false
            }
            self.client.sendMessageToServer(
                message: Message(.cards, players: [self.player])
            )
        default:
            break
        }
    }
    
    @IBAction func clickFold(_ sender: Any) {
        self.fold()
    }
    
    @IBAction func changeSliderValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        if self.player.status == .bet {
            self.actionButton.setTitle("Bet (\(currentValue))", for: UIControl.State.normal)
        }
    }
    
}

extension GameVC: ClientGameDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        if self.client.session.connectedPeers.count == 1 {
            // Insufficient players in the lobby
            let alert = UIAlertController(
                title: "Exit from lobby",
                message: "Insufficient number of players",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Ok",
                style: .default,
                handler: {(action) in
                    self.client.disconnect()
                    self.dealer?.timer?.invalidate()
                    self.dealer?.server.disconnect()
                    self.performSegue(withIdentifier: "backToMainSegue", sender: Any?.self)
                }
            ))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        } else {
            if peerID == self.client.serverPeerID {
                // Server disconnected
                var alert: UIAlertController
                if self.dealer == nil {
                    // Server disconnected from a guest
                    alert = UIAlertController(
                        title: "Exit from lobby",
                        message: "Lost connection with the host",
                        preferredStyle: .alert
                    )
                } else {
                    // Server disconnected from the host
                    alert = UIAlertController(
                        title: "Exit from lobby",
                        message: "Lost connection with the clients",
                        preferredStyle: .alert
                    )
                }
                alert.addAction(UIAlertAction(
                    title: "Ok",
                    style: .default,
                    handler: {(action) in
                        self.client.disconnect()
                        self.dealer?.timer?.invalidate()
                        self.dealer?.server.disconnect()
                        self.performSegue(withIdentifier: "backToMainSegue", sender: Any?.self)
                    }
                ))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            } else {
                // Player disconnected
                DispatchQueue.main.async {
                    for btn in self.playersButtons {
                        if btn.title(for: UIControl.State.normal) == peerID.displayName {
                            btn.isEnabled = false
                        }
                    }
                }
            }
        }
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        // MARK: StartMatch
        case .startMatch:
            DispatchQueue.main.async {
                // Initialization of data
                self.maxBid = 0
                self.totalBid = 0
                self.players = message.players!
                self.setupPlayers()
                // Initialization of UI
                self.statusLabel.text = "The game will start soon"
                self.timerLabel.text = String(Utils.timerShort)
                // TODO: change action, fold and slider visibility?
                for btn in self.playersButtons + self.cardsButtons {
                    btn.isHidden = true
                }
                // Start the timer
                var timerCounter = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerShort - timerCounter)
                    if timerCounter == Utils.timerShort {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Match started!"
                        self.timerLabel.text = ""
                        for btn in self.playersButtons + self.cardsButtons {
                            btn.isHidden = false
                        }
                    }
                }
            }
        // MARK: StartBet
        case .startBet:
            DispatchQueue.main.async {
                // Change data
                self.player.status = .bet
                self.isClicked = false
                // Change UI
                self.statusLabel.text = "Start Bet!"
                self.timerLabel.text = String(Utils.timerLong)
                self.actionButton.setTitle("Bet (0)", for: UIControl.State.normal)
                self.setupUserButton(withSlider: true, turnOn: true)
                // Set timer
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerLong - timerCounter)
                    if timerCounter == Utils.timerLong {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Stop Bet!"
                        self.timerLabel.text = ""
                        self.setupUserButton(withSlider: true, turnOn: false)
                    }
                }
            }
        // MARK: StopBet
        case .stopBet:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                var message: String
                if self.isClicked == false || self.player.bid == 0 {
                    // The player didn't bet
                    self.fold()
                    message = "You didn't bet"
                } else {
                    message = "Stop bet"
                }
                // Change UI
                self.statusLabel.text = message
                self.timerLabel.text = ""
                self.setupUserButton(withSlider: true, turnOn: false)
            }
        // MARK: StartCheck
        case .startCheck:
            DispatchQueue.main.async {
                // Change UI
                self.statusLabel.text = "Start Check!"
                self.timerLabel.text = String(Utils.timerLong)
                // Change data
                self.maxBid = message.amount!
                self.isClicked = false
                // Control if player can check/all-in
                if self.player.bid != self.maxBid {
                    let diff = self.maxBid - self.player.bid
                    if diff < self.player.points {
                        // Check
                        self.player.status = .check
                        self.actionButton.setTitle("Check +\(diff)", for: UIControl.State.normal)
                    } else {
                        // All-in
                        self.player.status = .allIn
                        self.actionButton.setTitle("All-in", for: UIControl.State.normal)
                    }
                    // Change UI
                    self.setupUserButton(withSlider: false, turnOn: true)
                }
                // Set timer
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerLong - timerCounter)
                    if timerCounter == Utils.timerLong {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Stop Check!"
                        self.timerLabel.text = ""
                        self.setupUserButton(withSlider: false, turnOn: false)
                    }
                }
            }
        // MARK: StopCheck
        case .stopCheck:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                var message: String
                if self.isClicked == false && self.player.bid != self.maxBid {
                    // The player didn't check
                    self.fold()
                    message = "You didn't check"
                } else {
                    message = "Stop check"
                }
                // Change UI
                self.statusLabel.text = message
                self.timerLabel.text = ""
                self.setupUserButton(withSlider: false, turnOn: false)
            }
        // MARK: StartCards
        case .startCards:
            DispatchQueue.main.async {
                // Change data
                self.player.status = .cards
                self.isClicked = false
                // Change UI
                self.statusLabel.text = "Start pick cards!"
                self.timerLabel.text = String(Utils.timerLong)
                self.actionButton.setTitle("Pick cards", for: UIControl.State.normal)
                self.setupUserButton(withSlider: false, turnOn: true)
                self.checkPickedCards()
                // Set timer
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerLong - timerCounter)
                    if timerCounter == Utils.timerLong {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Stop Cards!"
                        self.timerLabel.text = ""
                        self.setupUserButton(withSlider: false, turnOn: false)
                        for btn in self.cardsButtons {
                            btn.isEnabled = false
                        }

                    }
                }
            }
        // MARK: StopCards
        case .stopCards:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                if self.isClicked == false {
                    // The player didn't pick any cards
                    self.fold()
                }
                // Change UI
                self.statusLabel.text = "Stop Cards!"
                self.timerLabel.text = ""
                self.setupUserButton(withSlider: false, turnOn: false)
                for btn in self.cardsButtons {
                    btn.isEnabled = false
                }
            }
        // MARK: EndMatch
        case .endMatch:
            DispatchQueue.main.async {
                self.totalBid = message.amount!
                self.players = message.players!
                self.performSegue(withIdentifier: "showEndSegue", sender: nil)
            }

        case .resPlayer:
            DispatchQueue.main.async {
                self.userData?.message = "Points: \(message.players![0].points)\nBid: \(message.players![0].bid)"
                self.userDataSpinner?.stopAnimating()
            }

        default:
            print("ClientGameVC.didReceiveMessageFrom - message.type == \(message.type)")
        }
    }
    
}
