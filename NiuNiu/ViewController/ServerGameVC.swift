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
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dealer.delegate = self
        
        var timerCounter = 0
        self.statusLabel.text = "The game will start soon"
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.timerLabel.text = String(Utils.timer5 - timerCounter)
            if timerCounter == Utils.timer5 {
                timer.invalidate()
                self.dealer.play()
            } else {
                timerCounter += 1
            }
        }
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
            message: "Points: \(player.points)",
            preferredStyle: UIAlertController.Style.actionSheet
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        self.present(alert, animated: true)
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

    @IBAction func bet(_ sender: Any) {
        if self.betButton.title(for: UIControl.State.normal)!.hasPrefix("Bet") {
            let bid = Int(self.betSlider.value)
            self.himself.bid = bid
            self.pointsLabel.text = "Points: \(String(self.himself.points - bid)) (\(bid))"
        } else {
            self.betButton.isEnabled = false
            if self.betButton.title(for: UIControl.State.normal) == "Check" {
                self.pointsLabel.text = "Points: \(String(self.himself.points - maxBid)) (\(maxBid))"
            }
            if self.betButton.title(for: UIControl.State.normal) == "All-in" {
                self.himself.status = .allIn
                self.pointsLabel.text = "Points: 0"
            }
        }
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

extension ServerGameVC: DealerDelegate {
    
    func didStartMatch(users: [User]) {
        self.statusLabel.text = "Match started!"
        self.himself = self.dealer.himself
        var index = 0
        for user in users {
            if user.name == self.himself.id.displayName {
                // Setup himself cards
                self.himself.cards = user.cards
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
                self.playersButton[index].setTitle(users[index].name, for: UIControl.State.normal)
                self.playersButton[index].isEnabled = true
                index += 1
            }
        }
        
    }
        
    func didStartBet() {
        self.statusLabel.text = "Start Bet!"
        // Enable buttons
        self.betSlider.isEnabled = true
        self.betButton.isEnabled = true
        self.foldButton.isEnabled = true
        
        self.setTimer(time: Utils.timer30)
    }
    
    func didStopBet() {
        self.statusLabel.text = "Stop Bet!"
        // Block buttons
        self.betSlider.isEnabled = false
        self.betButton.isEnabled = false
        self.foldButton.isEnabled = false
        // Set points
        self.himself.points = self.himself.points - self.himself.bid
        self.pointsLabel.text = String(self.himself.points)
    }
    
    func didStartCheck(maxBid: Int) {
        self.statusLabel.text = "Start Fix Bid!"
        // Check if the player is the lead
        self.maxBid = maxBid
        if self.himself.bid != maxBid {
            let diff = maxBid - self.himself.bid
            if diff > 0 {
                // Setup bet button and labels
                self.betButton.setTitle("Check (+\(diff)", for: UIControl.State.normal)
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
        
        self.setTimer(time: Utils.timer30)
    }
    
    func didStopCheck() {
        self.statusLabel.text = "Stop Fix Bid!"
        // Block buttons
        self.betButton.isEnabled = false
        self.foldButton.isEnabled = false
        if self.betButton.title(for: UIControl.State.normal) == "All-in" {
            self.himself.status = .allIn
        }
        // Set points
        self.himself.points = self.himself.points - self.himself.bid
        self.pointsLabel.text = String(self.himself.points)
    }
    
    func didStartCards() {
        
    }
    
    func didStopCards() {
        
    }
    
    func didEndMatch(users: [User]) {
        
    }
    
    
}


