//
//  ServerGameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ServerGameViewController: UIViewController {
    
    // MARK: Properties
    var dealer: Dealer!
    var himself: Player!
    
    var myPeerID: MCPeerID!
    var serverPeerID: MCPeerID!
    
    var bidValue = 0
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var playersLabel: [UILabel]!
    @IBOutlet var cardsButton: [UIButton]!
    
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
    @IBAction func bet(_ sender: Any) {
    
    }
    
    @IBAction func clickCard(_ sender: UIButton) {
        // UI
        if let index = self.cardsButton.firstIndex(of: sender) {
            if self.clickedButtons[index] == false {
                self.clickedButtons[index] = true
                sender.layer.cornerRadius = 3
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
        self.bidLabel.text = "Your bid: \(currentValue) points"
    }
}

extension ServerGameViewController: DealerDelegate {
    
    func didStartGame(player: Player) {
        self.himself = player
        DispatchQueue.main.async {
            self.statusLabel.text = "Game started!"
            self.userLabel.text = self.himself.id.displayName
            self.pointsLabel.text = "Points: \(self.himself.points)"
            self.bidLabel.text = "Your bid: \(self.bidValue) points"
            self.bidSlider.minimumValue = Float(self.bidValue)
            self.bidSlider.maximumValue = Float(self.himself.points)
        }
    }
    
    func didStartMatch(players: Players) {
        // Comunica i dati degli altri giocatori
    }
    
    
    func didReceiveCards(cards: Cards) {
        self.himself.setCards(cards: cards)
        for index in 0...4 {
            DispatchQueue.main.async {
                let image = UIImage(named: cards.elements[index].getName())
                self.cardsButton[index].setBackgroundImage(image, for: UIControl.State.normal)
            }
        }
    }
    
    
    
}


