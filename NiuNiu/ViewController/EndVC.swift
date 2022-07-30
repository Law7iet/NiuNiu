//
//  EndViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 23/07/22.
//

import MultipeerConnectivity

class EndVC: UIViewController {

    // MARK: Properties
    var dealer: Dealer?
    var client: Client!
    var users: [Player]!
    var prize: Int!
    
    var play = false
    
    @IBOutlet weak var winnerID: UILabel!
    @IBOutlet weak var winnerPoints: UILabel!
    @IBOutlet weak var winnerScore: UILabel!
    @IBOutlet var winnerCards: [UIButton]!
    
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
    
    // MARK: Supporting functions
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
    
    func setupUsers() {
        if self.dealer != nil {
            self.users = [Player]()
            for player in self.dealer!.players {
                self.users?.append(player)
            }
        }
    }
    
    func setupUI() {
        var userIndex = 0
        for user in self.users! {
            if user.status == .winner {
                // Manage the winner
                self.winnerID.text = user.id
                self.winnerPoints.text = "Points: \(user.points - self.prize) + \(self.prize!)"
                self.winnerScore.text = user.score.description
                self.setupCard(buttons: self.winnerCards, cards: user.cards, pickedCards: user.pickedCards)
            } else {
                self.playerIDs[userIndex].text = user.id
                self.playerPoints[userIndex].text = "Points: \(user.points)"
                if user.status == .fold {
                    self.playerScore[userIndex].text = "Fold"
                } else {
                    self.playerScore[userIndex].text = user.score.description
                }
                self.setupCard(buttons: self.playerCards[userIndex]!, cards: user.cards, pickedCards: user.pickedCards)
                userIndex += 1
            }
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.client.endDelegate = self
        self.setupUsers()
        self.setupUI()
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if timerCounter >= Utils.timerLong {
                timer.invalidate()
                if self.play == true {
                    self.performSegue(withIdentifier: "backToGameSegue", sender: self)
                } else {
                    self.dealer?.server.disconnect()
                    self.client.disconnect()
                    self.performSegue(withIdentifier: "backToMainSegue", sender: self)
                }
            } else {
                if self.play == false {
                    self.endLabel.text = "Do you want to continue playing? (\(Utils.timerLong - timerCounter))"
                } else {
                    self.endLabel.text = "Next match will start in \(Utils.timerLong - timerCounter) seconds"
                }
                timerCounter += 1
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameVC {
            gameVC.dealer = self.dealer
            gameVC.client = self.client
        }
    }
    
    // MARK: Actions
    @IBAction func quit(_ sender: Any) {
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
                self.dealer?.server.disconnect()
                self.client.disconnect()
                self.performSegue(withIdentifier: "backToMainSegue", sender: self)
            }
        ))
        self.present(alert, animated: true)
    }
    
    @IBAction func play(_ sender: Any) {
        self.play = true
        self.playButton.isEnabled = false
    }

}

extension EndVC: ClientEndDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        if peerID == self.client.serverPeerID && self.dealer == nil {
            let alert = UIAlertController(
                title: "Exit from lobby",
                message: "The lobby has been closed",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Ok",
                style: .default,
                handler: {(action) in
                    self.client.disconnect()
                    self.performSegue(withIdentifier: "backToMainSegue", sender: Any?.self)
                }
            ))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
}
