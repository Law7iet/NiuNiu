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
    var player: Player!
    var users: [User]!
    
    var rounds = 0
    var time = 0
    var maxBid = 0
    var totalBid = 0
    var isClicked = false
    var clickedButtons = [false, false, false, false, false]
    var timer: Timer?
    var userData: UIAlertController?
    var userDataSpinner: UIActivityIndicatorView?
    
    var forceGameOver = false
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var foldLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet var playersLabel: [UILabel]!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var playersButtons: [UIButton]!
    @IBOutlet var cardsButtons: [UIButton]!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var betSlider: UISlider!
    
    // MARK: Supporting functions
    func setupMenu() {
        let quitAction = UIAction(title: "Quit", image: UIImage(systemName: "rectangle.portrait.and.arrow.right")) { (action) in
            let message = self.dealer != nil ? Utils.confermHostLeftMessage : Utils.confermClientLeftMessage
            let alert = UIAlertController(
                title: "Quit the game",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "No",
                style: .default
            ))
            alert.addAction(UIAlertAction(
                title: "Yes",
                style: .destructive,
                handler: { action in
                    // Notify and exit or close
                    self.dealer?.server.disconnect()
                    self.player.client.disconnect()
                    // Stats
                    Statistics.increaseGamesPlayed()
                    self.performSegue(withIdentifier: "backToMainSegue", sender: self)
                }
            ))
            self.present(alert, animated: true)
        }
        let menu = UIMenu(title: "Menu", options: .displayInline, children: [quitAction])
        self.menuButton.menu = menu
    }
    
    func setupPlayers() {
        var index = 0
        for user in self.users {
            if user.id == self.player.client.peerID.displayName {
                // Setup himself cards
                self.player.setupUser(user)
                for cardIndex in 0 ... 4 {
                    let image = UIImage(named: self.player.cards[cardIndex].fileName)
                    self.cardsButtons[cardIndex].setBackgroundImage(image, for: .normal)
                    self.cardsButtons[cardIndex].setBackgroundImage(image, for: .disabled)
                }
                // Setup himself labels
                self.playerLabel.text = self.player.id
                self.pointsLabel.text = "Points: \(self.player.points)"
                self.betSlider.minimumValue = 1.0
                self.betSlider.maximumValue = Float(self.player.points)
                self.betSlider.value = 1.0
            } else {
                // Setup the other players
                self.playersButtons[index].setAttributedTitle(
                    Utils.myString(user.id),
                    for: .normal
                )
                self.playersButtons[index].isEnabled = true
                index += 1
            }
        }
    }
    
    func setupUserButton(withSlider flag: Bool, turnOn: Bool) {
        if self.player.status == .fold {
            self.actionButton.isEnabled = false
            self.foldButton.isEnabled = false
            self.betSlider.isEnabled = false
        } else {
            if turnOn {
                self.actionButton.isEnabled = true
                self.foldButton.isEnabled = true
                if flag {
                    self.betSlider.isEnabled = true
                }
            } else {
                self.actionButton.isEnabled = false
                self.foldButton.isEnabled = false
                if flag {
                    self.betSlider.isEnabled = false
                }
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
    
    func foldAction() {
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
        self.player.client.sendMessageToServer(message: Message(.fold, users: [self.player]))
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMenu()
        self.player.gameDelegate = self
        // Hide UI
        for btn in self.playersButtons + self.cardsButtons {
            btn.isHidden = true
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.dealer?.play()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.dealer?.timer?.invalidate()
        if let endVC = segue.destination as? EndVC {
            endVC.dealer = self.dealer
            endVC.player = self.player
            endVC.users = self.users
            endVC.prize = self.totalBid
            endVC.isGameOver = self.forceGameOver
            endVC.rounds = self.rounds            
            for player in self.users {
                if player.points <= 0 {
                    endVC.isGameOver = true
                }
            }
        }
    }
    
    // MARK: Actions
    @IBAction func clickPlayer(_ sender: UIButton) {
        let player = Utils.findPlayer(byName: sender.currentAttributedTitle!.string, from: self.users)!
        // Setting the action sheet view
        self.userData = UIAlertController(
            title: player.id,
            message: "Fetching data...\n\n",
            preferredStyle: .actionSheet
        )
        self.userData!.addAction(UIAlertAction(title: "Close", style: .cancel))
        self.userDataSpinner = UIActivityIndicatorView(frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 30,
            y: 60,
            width: 40,
            height: 40
        ))
        self.userDataSpinner!.startAnimating();
        self.userData!.view.addSubview(self.userDataSpinner!)
        self.present(self.self.userData!, animated: true, completion: nil)
        // Send request data
        self.player.client.sendMessageToServer(message: Message(.reqPlayer, users: [player]))
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        // Animation of the card
        if let index = self.cardsButtons.firstIndex(of: sender) {
            self.player.clickCard(atIndex: index)
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
        // Change data and UI
        self.isClicked = true
        self.setupUserButton(withSlider: true, turnOn: false)
        // Action
        switch self.player.status {
        case .bet:
            let bid = Int(self.betSlider.value)
            if bid == 0 {
                self.foldAction()
            } else {
                self.player.bet(amount: bid)
                self.pointsLabel.text = "Points: \(String(self.player.points)) (\(bid))"
                self.player.client.sendMessageToServer(message: Message(.bet, users: [self.player]))
            }
        case .check:
            let diff = self.maxBid - self.player.bid
            self.player.check(amount: diff)
            self.pointsLabel.text = "Points: \(String(self.player.points)) (\(self.maxBid))"
            self.betSlider.value = Float(self.player.bid + self.player.fixBid)
            self.player.client.sendMessageToServer(message: Message(.check, users: [self.player]))
        case .allIn:
            self.player.allIn()
            self.pointsLabel.text = "Points: 0 (\(self.player.bid + self.player.fixBid)"
            self.betSlider.value = Float(self.player.bid + self.player.fixBid)
            self.player.client.sendMessageToServer(message: Message(.check, users: [self.player]))
        case .cards:
            self.player.chooseCards(
                cards: self.player.cards,
                pickedCards: self.player.pickedCards,
                numberOfPickedCards: self.player.numberOfPickedCards,
                tieBreakerCard: self.player.tieBreakerCard,
                score: self.player.score
            )
            self.actionButton.setAttributedTitle(
                Utils.myString("Cards picked"),
                for: .normal
            )
            for btn in self.cardsButtons {
                btn.isEnabled = false
            }
            self.player.client.sendMessageToServer(message: Message(.cards, users: [self.player]))
        default:
            break
        }
    }
    
    @IBAction func clickFold(_ sender: Any) {
        self.foldAction()
    }
    
    @IBAction func changeSliderValue(_ sender: UISlider) {
        if self.player.status == .bet {
            self.actionButton.setAttributedTitle(
                Utils.myString("Bet (\(Int(sender.value)))"),
                for: .normal
            )
        }
    }
    
}
