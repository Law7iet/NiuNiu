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
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var playersButton: [UIButton]!
    @IBOutlet var cardsButton: [UIButton]!
    @IBOutlet weak var betButton: UIButton!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidSlider: UISlider!
    
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
        self.himself.bid = self.bidValue
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
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.bidValue = currentValue
        self.bidLabel.text = "Your bid: \(currentValue) points"
    }
}

extension ServerGameVC: DealerDelegate {
    
    func didStartGame(player: Player) {
        self.himself = player
        self.statusLabel.text = "Game started!"
        self.userLabel.text = self.himself.id.displayName
        self.pointsLabel.text = "Points: \(self.himself.points)"
        self.bidLabel.text = "Your bid: \(self.bidValue) points"
        self.bidSlider.minimumValue = Float(self.bidValue)
        self.bidSlider.maximumValue = Float(self.himself.points)
    }
    
    func didStartMatch(users: [User]) {
        // Comunica i dati degli altri giocatori
        for index in 0 ..< users.count {
            self.playersButton[index].setTitle(users[index].name, for: UIControl.State.normal)
            self.playersButton[index].isEnabled = true
        }
    }
    
    func didReceiveCards(cards: Cards) {
        self.himself.setCards(cards: cards)
        for index in 0 ... 4 {
            let image = UIImage(named: cards.elements[index].getName())
            self.cardsButton[index].setBackgroundImage(image, for: UIControl.State.normal)
        }
    }
    
    func didStartBet() {
        self.bidSlider.isEnabled = true
        self.betButton.isEnabled = true
    }
    
    func didStopBet() {
        self.bidSlider.isEnabled = false
        self.betButton.isEnabled = false
    }
}


