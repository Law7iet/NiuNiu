//
//  ServerGameVC.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ServerGameVC: UIViewController {
    
    // MARK: Properties
    var dealer: Dealer!
    var himself: Player!
    
    var maxBid = 0
    
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidSlider: UISlider!
    
    @IBOutlet var playersButton: [UIButton]!
    @IBOutlet var cardsButton: [UIButton]!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var foldButton: UIButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dealer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.dealer.playGame()
    }
    
    // MARK: Actions
    @IBAction func home(_ sender: Any) {
        let alert = UIAlertController(
            title: "Quit the game",
            message: "If you quit the game, the game will end. Are you sure to quit?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "No", style: .default)
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { action in
                self.dealer.comms.sendMessage(
                    to: self.dealer.comms.connectedPeerIDs,
                    message: Message(.closeSession)
                )
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            })
        )
        self.present(alert, animated: true)
    }
    
    @IBAction func clickPlayer(_ sender: UIButton) {
        let player = self.dealer.players.findPlayer(byName: sender.currentTitle!)!
        let alert = UIAlertController(
            title: player.id.displayName,
            message: "Points: \(player.points)\nBid: \(player.bid)",
            preferredStyle: UIAlertController.Style.actionSheet
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func bet(_ sender: Any) {
        if self.betButton.title(for: UIControl.State.normal) == "Bet" {
            let bid = Int(self.bidSlider.value)
            self.himself.bid = bid
            self.pointsLabel.text = "Points: \(String(self.himself.points - bid)) (\(bid)"
        } else {
            self.betButton.isEnabled = false
            if self.betButton.title(for: UIControl.State.normal) == "Check" {
                self.pointsLabel.text = "Points: \(String(self.himself.points - maxBid)) (\(maxBid)"
            }
            if self.betButton.title(for: UIControl.State.normal) == "All in!" {
                self.pointsLabel.text = "Points: 0"
            }
        }
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        // UI
        if let index = self.cardsButton.firstIndex(of: sender) {
            if self.clickedButtons[index] == false {
                self.clickedButtons[index] = true
                sender.layer.cornerRadius = 5
                sender.layer.borderWidth = 3
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
        self.himself.status = .fold
    }

}

extension ServerGameVC: DealerDelegate {
    
    func didStartGame(player: Player) {
        self.statusLabel.text = "Game started!"
        // Initialize himself
        self.himself = player
        self.userLabel.text = self.himself.id.displayName
        self.pointsLabel.text = "Points: \(self.himself.points)"
        self.bidLabel.text = "Bid: \(self.himself.bid) points"
        self.bidSlider.minimumValue = 0.0
        self.bidSlider.maximumValue = Float(self.himself.points)
    }
    
    func didStartMatch(users: [User]) {
        self.statusLabel.text = "Match started!"
        // Setup the other players
        for index in 0 ..< users.count {
            self.playersButton[index].setTitle(users[index].name, for: UIControl.State.normal)
            self.playersButton[index].isEnabled = true
        }
    }
    
    func didReceiveCards(cards: Cards) {
        self.statusLabel.text = "Cards received!"
        // Setup cards
        self.himself.setCards(cards: cards)
        for index in 0 ... 4 {
            let image = UIImage(named: cards.elements[index].getName())
            self.cardsButton[index].setBackgroundImage(image, for: UIControl.State.normal)
        }
    }
    
    func didStartBet() {
        self.statusLabel.text = "Start Bet!"
        // Enable buttons
        self.bidSlider.isEnabled = true
        self.betButton.isEnabled = true
        self.foldButton.isEnabled = true
    }
    
    func didStopBet() {
        self.statusLabel.text = "Stop Bet!"
        // Block buttons
        self.bidSlider.isEnabled = false
        self.betButton.isEnabled = false
        self.foldButton.isEnabled = false
        // Set points
        self.himself.points = self.himself.points - self.himself.bid
        self.pointsLabel.text = String(self.himself.points)
    }
    
    func didStartFixBid(maxBid: Int) {
        self.statusLabel.text = "Start Fix Bid!"
        // Check if the player is the lead
        self.maxBid = maxBid
        if self.himself.bid != maxBid {
            let diff = maxBid - self.himself.bid
            if diff > 0 {
                // Setup bet button and labels
                self.betButton.setTitle("Check", for: UIControl.State.normal)
                self.betButton.isEnabled = true
                self.foldButton.isEnabled = true
                self.bidLabel.text = self.bidLabel.text! + " (+\(diff)"
            } else {
                // The user doens't have enough points
                // He can "all-in" or "fold"
                self.betButton.setTitle("All in!", for: UIControl.State.normal)
                self.betButton.isEnabled = true
                self.foldButton.isEnabled = true
            }
        }
    }
    
    func didStopFixBid() {
        self.statusLabel.text = "Stop Fix Bid!"
        // Block buttons
        self.betButton.isEnabled = false
        self.foldButton.isEnabled = false
        // Set points
        self.himself.points = self.himself.points - self.himself.bid
        self.pointsLabel.text = String(self.himself.points)
    }
    
    func didReceiveTimer(timer: Int) {
        self.timerLabel.text = String(timer)
    }
}


