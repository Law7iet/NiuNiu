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
    var totalBid = 0
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet var playersButton: [UIButton]!
    @IBOutlet var cardsButton: [UIButton]!
    @IBOutlet weak var pickButton: UIButton!
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
            self.timerLabel.text = String(Utils.timerShort - timerCounter)
            if timerCounter == Utils.timerShort {
                timer.invalidate()
                self.dealer.play()
            } else {
                timerCounter += 1
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let endVC = segue.destination as? EndViewController {
            endVC.server = self.dealer
            endVC.himself = self.himself
            endVC.prize = self.dealer.totalBid
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
                    to: self.dealer.comms.clients,
                    message: Message(.closeSession)
                )
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            })
        )
        self.present(alert, animated: true)
    }
    
    @IBAction func clickPlayer(_ sender: UIButton) {
        let player = Utils.findPlayer(byName: sender.currentTitle!, from: self.dealer.players.elements)!
        let alert = UIAlertController(
            title: player.id.displayName,
            message: "Points: \(player.points)",
            preferredStyle: UIAlertController.Style.actionSheet
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        if self.himself.status == .cards {
            if let index = self.cardsButton.firstIndex(of: sender) {
                self.himself.cards!.pickCardAt(index: index)
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
            if self.himself.cards!.numberOfPickedCards == 1 || self.himself.cards!.numberOfPickedCards == 3 {
                self.pickButton.isEnabled = true
            } else {
                self.pickButton.isEnabled = false
            }
        }
    }
    
    @IBAction func pickCards(_ sender: Any) {
        self.pickButton.isEnabled = false
        self.foldButton.isEnabled = false
    }

    @IBAction func fold(_ sender: Any) {
        self.foldButton.isEnabled = false
        self.betButton.isEnabled = false
        self.betSlider.isEnabled = false
        // TODO: Turnoff pickCards button
        for btn in self.cardsButton {
            btn.isEnabled = false
        }
        self.statusLabel.text = "Fold"
        self.himself.status = .fold
    }

    @IBAction func bet(_ sender: Any) {
        switch self.himself.status {
        case .bet:
            let bid = Int(self.betSlider.value)
            self.pointsLabel.text = "Points: \(String(self.himself.points - bid)) (\(bid))"
            self.himself.bid = bid
            self.himself.points = self.himself.points - bid
        case .check:
            let diff = self.maxBid - self.himself.bid
            self.pointsLabel.text = "Points: \(String(self.himself.points - diff)) (\(self.maxBid))"
            self.himself.bid = diff
            self.himself.points = self.himself.points - diff
        case .allIn:
            let diff = self.maxBid - self.himself.points
            self.pointsLabel.text = "Points: 0"
            self.himself.bid = diff
            self.himself.points = 0
        default:
            return
        }
        self.betButton.isEnabled = false
        self.foldButton.isEnabled = false
    }
    
    @IBAction func changeSliderValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        let buttonTitle = self.betButton.title(for: UIControl.State.normal)
//        if self.himself.status == .bet
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
        if self.himself.status != .fold {
            self.himself.status = .bet
            self.statusLabel.text = "Start Bet!"
            self.betSlider.isEnabled = true
            self.betButton.isEnabled = true
            self.foldButton.isEnabled = true
            self.setTimer(time: Utils.timerLong)
        }
    }
    
    func didStopBet() {
        if self.himself.status != .fold {
            self.himself.status = .none
            self.statusLabel.text = "Stop Bet!"
            self.betSlider.isEnabled = false
            self.betButton.isEnabled = false
            self.foldButton.isEnabled = false
        }
    }
    
    func didStartCheck(maxBid: Int) {
        if self.himself.status != .fold {
            self.statusLabel.text = "Start Check!"
            self.maxBid = maxBid
            if self.himself.bid != maxBid {
                let diff = maxBid - self.himself.bid
                if diff > 0 {
                    // Setup bet button and labels
                    self.himself.status = .check
                    self.betButton.setTitle("Check +\(diff)", for: UIControl.State.normal)
                    self.betButton.isEnabled = true
                    self.foldButton.isEnabled = true
                } else if diff < 0 {
                    // The user doens't have enough points
                    self.himself.status = .allIn
                    self.betButton.setTitle("All-in", for: UIControl.State.normal)
                    self.betButton.isEnabled = true
                    self.foldButton.isEnabled = true
                }
            }
            self.setTimer(time: Utils.timerLong)
        }
    }
    
    func didStopCheck() {
        if self.himself.status != .fold {
            self.himself.status = .none
            self.statusLabel.text = "Stop Check!"
            self.betButton.isEnabled = false
            self.foldButton.isEnabled = false
        }
    }
    
    func didStartCards() {
        if self.himself.status != .fold {
            self.statusLabel.text = "Start pick cards!"
            self.himself.status = .cards
            self.setTimer(time: Utils.timerLong)
        }
    }
    
    func didStopCards() {
        self.statusLabel.text = "Stop cards!"
    }
    
    func didEndMatch(amount: Int, users: [User]) {
        self.totalBid = amount
        self.performSegue(withIdentifier: "showEndMatchSegue", sender: nil)
    }
    
    
}


