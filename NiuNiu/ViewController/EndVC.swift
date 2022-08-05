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
    var players: [Player]!
    var prize: Int!
    
    var play = false
    var isLost = false
    
    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBOutlet var playerIDs: [UILabel]!
    @IBOutlet var playerPoints: [UILabel]!
    @IBOutlet var playerScore: [UILabel]!
    // TODO: fix UI
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
            self.players = [Player]()
            for player in self.dealer!.players {
                self.players?.append(player)
            }
        }
    }
    
    func setupUI() {
        var playerIndex = 0
        for player in self.players {
            self.playerIDs[playerIndex].text = player.id
            if player.status == .winner {
                self.playerPoints[playerIndex].text = "Points: \(player.points - self.prize) + \(self.prize!)"
            } else {
                self.playerPoints[playerIndex].text = "Points: \(player.points)"
            }
            switch player.status {
            case .fold: self.playerScore[playerIndex].text = "Fold"
            case .disconnected: self.playerScore[playerIndex].text = "Disconnected"
            default: self.playerScore[playerIndex].text = player.score.description
            }
            self.setupCard(buttons: self.playerCards[playerIndex]!, cards: player.cards, pickedCards: player.pickedCards)
            playerIndex += 1
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.client.endDelegate = self
        self.setupUsers()
        self.setupUI()
        
        for player in self.players {
            if player.id == self.client.peerID.displayName {
                if player.points <= 0 {
                    // Can't continue playing
                    self.isLost = true
                    self.playButton.isEnabled = false
                } else {
                    // Can continue playing
                    self.isLost = false
                    self.playButton.isEnabled = true
                }
            }
        }
        
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if timerCounter >= Utils.timerLong {
                timer.invalidate()
                if self.isLost == false && self.play == true {
                    self.performSegue(withIdentifier: "backToGameSegue", sender: self)
                } else {
                    self.play = false
                    self.dealer?.server.disconnect()
                    self.client.disconnect()
                    self.endLabel.text = "Match started without you"
                }
            } else {
                self.endLabel.text = "Next match will start in \(Utils.timerLong - timerCounter) seconds"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("EndVC willAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("EndVC didAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("EndVC willDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("EndVC didDisappear")
    }
    
    // MARK: Actions
    @IBAction func quit(_ sender: Any) {
        if isLost == false {
            var message: String?
            if self.dealer != nil {
                message = "If you quit the game, the game will end. Are you sure to quit?"
            } else {
                if self.isLost == false {
                    message = "If you quit the game, you won't be able to play until the game ends. Are you sure to quit?"
                }
            }
            if message != nil {
                let alert = UIAlertController(
                    title: "Quit the game",
                    message: message!,
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
                        self.play = false
                        self.dealer?.server.disconnect()
                        self.client.disconnect()
                        self.performSegue(withIdentifier: "backToMainSegue", sender: self)
                    }
                ))
                self.present(alert, animated: true)
            } else {
                self.play = false
                self.dealer?.server.disconnect()
                self.client.disconnect()
                self.performSegue(withIdentifier: "backToMainSegue", sender: self)
            }
        } else {
            self.play = false
            self.dealer?.server.disconnect()
            self.client.disconnect()
            self.performSegue(withIdentifier: "backToMainSegue", sender: self)
        }
    }
    
    @IBAction func play(_ sender: Any) {
        self.play = true
        self.playButton.isEnabled = false
    }

}

extension EndVC: ClientEndDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        if peerID == self.client.serverPeerID && self.dealer == nil {
            self.play = false
            let alert = UIAlertController(
                title: "Exit from lobby",
                message: "The lobby has been closed",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Ok",
                style: .default,
                handler: {(action) in
                    self.playButton.isEnabled = false
                    self.client.disconnect()
                }
            ))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        } else if self.dealer?.server.connectedPeers.count == 1 {
            self.play = false
            let alert = UIAlertController(
                title: "Exit from lobby",
                message: "Insufficient number of players",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Ok",
                style: .default,
                handler: {(action) in
                    self.playButton.isEnabled = false
                    self.client.disconnect()
                }
            ))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
}
