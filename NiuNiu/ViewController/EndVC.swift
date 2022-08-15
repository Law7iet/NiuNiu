//
//  EndVC.swift
//  NiuNiu
//
//  Created by Han Chu on 23/07/22.
//

import MultipeerConnectivity

class EndVC: UIViewController {

    // MARK: Properties
    var dealer: Dealer?
    var client: Client!
    var players: [Player]!
    var prize: Int!
    var time: Int!
    
    var timer: Timer?
    var clickedPlayBtn = false
    var isGameOver = false
    var changeEndLabel = true
    
    @IBOutlet var playerIDs: [UILabel]!
    @IBOutlet var playerPoints: [UILabel]!
    @IBOutlet var playerScore: [UILabel]!

    @IBOutlet var cards1: [UIButton]!
    @IBOutlet var cards2: [UIButton]!
    @IBOutlet var cards3: [UIButton]!
    @IBOutlet var cards4: [UIButton]!
    @IBOutlet var cards5: [UIButton]!
    lazy var playerCards = [cards1, cards2, cards3, cards4, cards5]
    
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    
    // MARK: Supporting functions
    func setupViewDidLoad() {
        // Delegate
        self.client.endDelegate = self
        // Setup players and find if there's a loser
        if self.dealer != nil {
            self.players = [Player]()
            for player in self.dealer!.players {
                self.players?.append(player)
                if player.points <= 0 {
                    self.isGameOver = true
                }
            }
        }
    }
    
    func setupCard(buttons: [UIButton], cards: [Card], pickedCards: [Bool]) {
        var cardTrueIndex = 0
        var cardFalseIndex = 4
        for cardIndex in 0 ... 4 {
            let image = UIImage(named: cards[cardIndex].fileName)
            if pickedCards[cardIndex] == true {
                buttons[cardTrueIndex].setBackgroundImage(image, for: UIControl.State.normal)
                buttons[cardTrueIndex].layer.cornerRadius = Utils.cornerRadiusSmall
                buttons[cardTrueIndex].layer.borderWidth = Utils.borderWidth(withHeight: buttons[0].frame.height)
                buttons[cardTrueIndex].layer.borderColor = UIColor.red.cgColor
                cardTrueIndex += 1
            } else {
                buttons[cardFalseIndex].setBackgroundImage(image, for: UIControl.State.normal)
                cardFalseIndex -= 1
            }
        }
    }
    
    func setupPlayersUI() {
        var playerIndex = 0
        for player in self.players {
            // Setup the players
            self.playerIDs[playerIndex].text = player.id
            if player.status == .winner {
                self.playerPoints[playerIndex].text = "Points: \(player.points - self.prize) + \(self.prize!)"
                self.playerScore[playerIndex].text = "Winner: \(player.score.description)"
            } else {
                self.playerPoints[playerIndex].text = "Points: \(player.points)"
                self.playerScore[playerIndex].text = "\(player.score.description)"
            }
            switch player.status {
            case .fold: self.playerScore[playerIndex].text = "Fold"
            case .disconnected: self.playerScore[playerIndex].text = "Disconnected"
            default: break
            }
            self.setupCard(buttons: self.playerCards[playerIndex]!, cards: player.cards, pickedCards: player.pickedCards)
            playerIndex += 1
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewDidLoad()
        self.setupPlayersUI()

        // Setup endLabel and buttons
        if self.isGameOver == true {
            // UI
            self.endLabel.text = "Game over"
            self.changeEndLabel = false
            self.quitButton.setTitle("Quit", for: UIControl.State.normal)
            self.playButton.isEnabled = false
            // Disconnection
            self.client.disconnect()
            self.dealer?.server.disconnect()
        } else {
            var timerCounter = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                if timerCounter >= self.time {
                    timer.invalidate()
                    if self.clickedPlayBtn {
                        // UI
                        self.performSegue(withIdentifier: "backToGameSegue", sender: self)
                    } else {
                        // Data
                        self.timer?.invalidate()
                        self.clickedPlayBtn = false
                        self.isGameOver = true
                        // UI
                        self.endLabel.text = "Game over"
                        self.quitButton.setTitle("Quit", for: UIControl.State.normal)
                        self.playButton.isEnabled = false
                        // Disconnection
                        self.client.disconnect()
                        self.dealer?.server.disconnect()
                    }
                } else {
                    if self.changeEndLabel {
                        self.endLabel.text = "Next match will start in \(self.time - timerCounter) seconds"
                    }
                    timerCounter += 1
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameVC {
            gameVC.dealer = self.dealer
            gameVC.client = self.client
        }
    }
    
    // MARK: Actions
    @IBAction func quit(_ sender: Any) {
        if isGameOver == false {
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
                    // Data
                    self.timer?.invalidate()
                    self.clickedPlayBtn = false
                    self.isGameOver = true
                    // UI
                    self.endLabel.text = "Game over"
                    self.quitButton.setTitle("Quit", for: UIControl.State.normal)
                    self.playButton.isEnabled = false
                    self.timer?.invalidate()
                    // Disconnection
                    self.client.disconnect()
                    self.dealer?.server.disconnect()
                }
            ))
            self.present(alert, animated: true)
        } else {
            self.performSegue(withIdentifier: "backToMainSegue", sender: self)
        }
    }
    
    @IBAction func play(_ sender: Any) {
        self.clickedPlayBtn = true
        self.playButton.isEnabled = false
    }

}

// MARK: ClientEndDelegate implementation
extension EndVC: ClientEndDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        if !self.isGameOver {
            if self.client.session.connectedPeers.count == 1 {
                // Insufficient players in the lobby
                let alert = UIAlertController(
                    title: "Exit from lobby",
                    message: "Insufficient number of players",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(
                    title: "Ok",
                    style: .default
                ))
                DispatchQueue.main.async {
                    // Data
                    self.timer?.invalidate()
                    self.clickedPlayBtn = false
                    self.isGameOver = true
                    // UI
                    self.endLabel.text = "Game over"
                    self.quitButton.setTitle("Quit", for: UIControl.State.normal)
                    self.playButton.isEnabled = false
                    // Disconnection
                    self.client.disconnect()
                    self.dealer?.server.disconnect()
                    self.present(alert, animated: true)
                }
            } else if peerID == self.client.serverPeerID {
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
                    style: .default
                ))
                DispatchQueue.main.async {
                    // Data
                    self.timer?.invalidate()
                    self.clickedPlayBtn = false
                    self.isGameOver = true
                    // UI
                    self.endLabel.text = "Game over"
                    self.quitButton.setTitle("Quit", for: UIControl.State.normal)
                    self.playButton.isEnabled = false
                    // Disconnection
                    self.client.disconnect()
                    self.dealer?.server.disconnect()
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
}
