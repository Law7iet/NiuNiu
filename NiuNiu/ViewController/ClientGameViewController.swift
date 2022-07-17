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
    var clientManager: LobbyManager!
    var user: Player!
    
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
        clientManager.delegate = self
        // Do any additional setup after loading the view.
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
                sender.layer.borderWidth = 2
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
    
}

// MARK: LobbyManagerDelegate implementation
extension ClientGameViewController: LobbyManagerDelegate {
    
    // Not used
    func didConnectWith(peerID: MCPeerID) {}
    func didDisconnectWith(peerID: MCPeerID) {}
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        if peerID == self.clientManager.hostPeerID {
            let message = Message(data: messageData)
            switch message.type {
            case .startGame:
                print("startGame")
                let points = message.amount!
                self.user = Player(id: self.clientManager.myPeerID, points: points)
                DispatchQueue.main.async {
                    self.userLabel.text = self.user.id.displayName
                    self.pointsLabel.text = "Points: \(self.user.points)"
                    self.bidLabel.text = "Your bid: 0 points"
                }
//            case .startMatch:
//                print("startMatch")
            case .receiveCards:
                print("ReceiveCards")
                let cards = message.cards!
                self.user.setCards(cards: cards)
                for index in 0...4 {
                    DispatchQueue.main.async {
                        let image = UIImage(named: cards.elements[index].getName())
                        self.cardsButton[index].setBackgroundImage(image, for: UIControl.State.normal)
                    }
                }
//            case .startBet:
//                print("startBet")
//            case .endBet:
//                print("endBet")
//            case .startFixBid:
//                print("startFixBet")
//            case .endFixBid:
//                print("endFixBet")
//            case .startChooseCards:
//                print("startPickCards")
//            case .endChooseCards:
//                print("endPickCards")
//            case .showCards:
//                print("showCards")
//            case .winner:
//                print("declareWinner")
//            case .endMatch:
//                print("endMatch")
//            case .endGame:
//                print("endGame")
            // TODO: check if there're closeConnection or closeLobby
            default:
                print("???")
            }
        }
    }
    
}
