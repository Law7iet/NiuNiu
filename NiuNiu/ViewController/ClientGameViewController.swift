//
//  ClientGameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ClientGameViewController: UIViewController {

    // MARK: Properties
    var clientManager: Client!
    var himself: Player!
    
    var myPeerID: MCPeerID!
    var hostPeerID: MCPeerID!
    
    var bidValue = 0
    var clickedButtons = [false, false, false, false, false]
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var playersButton: [UIButton]!
    @IBOutlet var cardsButton: [UIButton]!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidSlider: UISlider!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        clientManager.clientDelegate = self
    }
    
    // MARK: Actions
    @IBAction func bet(_ sender: Any) {
    
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
    
    @IBAction func showPlayerData(_ sender: UIButton) {
        
    }
}

// MARK: LobbyManagerDelegate implementation
extension ClientGameViewController: ClientDelegate {
        
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        
        let message = Message(data: messageData)
        switch message.type {
        case .startGame:
            print("startGame")
            let points = message.amount!
            self.himself = Player(id: self.myPeerID, points: points)
            DispatchQueue.main.async {
                self.statusLabel.text = "Game started!"
                self.userLabel.text = self.himself.id.displayName
                self.pointsLabel.text = "Points: \(self.himself.points)"
                self.bidLabel.text = "Your bid: \(self.bidValue) points"
                self.bidSlider.minimumValue = Float(self.bidValue)
                self.bidSlider.maximumValue = Float(self.himself.points)
            }
        case .startMatch:
            print("startMatch")
            if let users = message.users {
                DispatchQueue.main.async {
                    for index in 0 ..< users.count {
                        self.playersButton[index].setTitle(users[index].name, for: UIControl.State.normal)
                        self.playersButton[index].isEnabled = true
                    }
                }
            }
        case .resCards:
            print("ReceiveCards")
            let cards = message.cards!
            self.himself.setCards(cards: cards)
            for index in 0...4 {
                DispatchQueue.main.async {
                    let image = UIImage(named: cards.elements[index].getName())
                    self.cardsButton[index].setBackgroundImage(image, for: UIControl.State.normal)
                }
            }
        case .startBet:
            print("startBet")
        case .endBet:
            print("endBet")
        case .startFixBid:
            print("startFixBet")
        case .endFixBid:
            print("endFixBet")
        case .startChooseCards:
            print("startPickCards")
        case .endChooseCards:
            print("endPickCards")
        case .showCards:
            print("showCards")
        case .winner:
            print("declareWinner")
        case .endMatch:
            print("endMatch")
        case .endGame:
            print("endGame")
        
        case .resPlayer:
            print("resPlayerData")
            DispatchQueue.main.async {
                let user = message.users![0]
                let message = "Points: \(user.points)\nBid: \(user.bid)"
                let alert = UIAlertController(
                    title: user.name,
                    message: message,
                    preferredStyle: .actionSheet
                )
                self.present(alert, animated: true)
            }
            
            
        // TODO: check if there're closeConnection or closeLobby
        default:
            print("???")
        }
    }
    
}
