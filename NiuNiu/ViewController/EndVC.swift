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
    
    var timer: Timer?
    var clickedPlayBtn = false
    var isGameOver = false
    var changeEndLabel = true
    
    @IBOutlet var playerIDs: [UILabel]!
    @IBOutlet var playerPoints: [UILabel]!
    @IBOutlet var playerScore: [UILabel]!
    @IBOutlet weak var titleLabel: UILabel!
    
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
    func setupStatistics() {
        Statistics.increaseRoundsPlayed()
        for player in self.players {
            if player.status == .winner {
                if player.id == self.client.peerID.displayName {
                    Statistics.increaseRoundsWon()
                    Statistics.addPointsGained(points: self.prize)
                }
            }
        }
    }
    
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
    
    func endGame() {
        // Statistics
        Statistics.increaseGamesPlayed()
        if self.client.peerID.displayName == self.players[0].id {
            // The player is the winner of the game
            Statistics.increaseGamesWon()
        }
        // Hide UI
        for cards in self.playerCards {
            for card in cards! {
                card.isHidden = true
            }
            for scoreLabel in self.playerScore {
                scoreLabel.isHidden = true
            }
        }
        // Change UI
        var index = 0
        for player in self.players {
            self.playerIDs[index].text = "\(index + 1). \(self.playerIDs[index].text!)"
            self.playerPoints[index].text = "Points: \(player.points)"
            index += 1
        }
        self.titleLabel.text = "Scoreboard"
        self.endLabel.text = "Game over"
        self.changeEndLabel = false
        self.quitButton.setAttributedTitle(
            Utils.myString("Quit"),
            for: .normal)
        self.playButton.isEnabled = false
        // Disconnection
        self.client.disconnect()
        self.dealer?.server.disconnect()
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewDidLoad()
        self.setupPlayersUI()
        self.setupStatistics()

        // Setup endLabel and buttons
        if self.isGameOver == true {
            self.endGame()
        } else {
            var timerCounter = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                if timerCounter >= Utils.timerMedium {
                    timer.invalidate()
                    if self.clickedPlayBtn {
                        // UI
                        self.performSegue(withIdentifier: "backToGameSegue", sender: self)
                    } else {
                        // Data
                        self.timer?.invalidate()
                        self.clickedPlayBtn = false
                        self.isGameOver = true
                        self.endGame()
                    }
                } else {
                    if self.changeEndLabel {
                        self.endLabel.text = "Next match will start in \(Utils.timerMedium - timerCounter) seconds"
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
    @IBAction func clickQuit(_ sender: Any) {
        if isGameOver == false {
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
                    // Data
                    self.timer?.invalidate()
                    self.clickedPlayBtn = false
                    self.isGameOver = true
                    self.endGame()
                }
            ))
            self.present(alert, animated: true)
        } else {
            self.performSegue(withIdentifier: "backToMainSegue", sender: self)
        }
    }
    
    @IBAction func clickPlay(_ sender: Any) {
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
                    self.endGame()
                    self.present(alert, animated: true)
                }
            } else if peerID == self.client.serverPeerID {
                // Server disconnected
                var alert: UIAlertController
                if self.dealer == nil {
                    // Server disconnected from a guest
                    alert = UIAlertController(
                        title: "Exit from lobby",
                        message: Utils.hostLeftMessage,
                        preferredStyle: .alert
                    )
                } else {
                    // Server disconnected from the host
                    alert = UIAlertController(
                        title: "Exit from lobby",
                        message: Utils.clientLeftMessage,
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
                    self.endGame()
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
}
