//
//  ServerGameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    // MARK: Variables
    var serverManager: ServerManager!
    var receiver: MCPeerID!
    var dealer: Dealer!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var playersLabel: [UILabel]!
    @IBOutlet var cardsButton: [UIButton]!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidSlider: UISlider!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serverManager.delegate = self
        self.dealer = Dealer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.serverManager.sendBroadcastMessage(Message(type: .startGame))
        self.dealer.shuffleCards()
        for player in self.serverManager.playersPeerID {
            let cards = self.dealer.getCards()
            self.serverManager.sendMessageTo(receiver: player, message: Message(type: .receiveCards, text: nil, cards: cards))
        }
        // TODO: Start timer
        self.serverManager.sendBroadcastMessage(Message(type: .startBet))
        // TODO: Timer ends
        self.serverManager.sendBroadcastMessage(Message(type: .endBet))
        // TODO: Change status to the players whose didn't bet
        var playersAvailable = [Player]()
        // TODO: Start timer
        for player in playersAvailable {
            self.serverManager.sendMessageTo(receiver: player.id, message: Message(type: .startFixBet))
        }
        // TODO: Timer ends
        for player in playersAvailable {
            self.serverManager.sendMessageTo(receiver: player.id, message: Message(type: .endFixBet))
        }
        // TODO: Change status to the players whose didn't fixbet
        playersAvailable = [Player]()
        // TODO: Start timer
        for player in playersAvailable {
            self.serverManager.sendMessageTo(receiver: player.id, message: Message(type: .startPickCards))
        }
        // TODO: Timer ends
        for player in playersAvailable {
            self.serverManager.sendMessageTo(receiver: player.id, message: Message(type: .endPickCards))
        }
        // TODO: Change status to the players whose didn't pickCards
        playersAvailable = [Player]()
        // TODO: Compute the winner
        for player in playersAvailable {
            self.serverManager.sendMessageTo(receiver: player.id, message: Message(type: .showCards))
        }
        // TODO: notify the winner
        // TODO: Give to the winner the prize
        self.serverManager.sendBroadcastMessage(Message(type: .endMatch))

        
    }
    
    // MARK: Actions
    @IBAction func bet(_ sender: Any) {
    
    }
    
    @IBAction func clickCard(_ sender: Any) {
        
    }
}

extension GameViewController: ServerManagerDelegate {
    
    func didConnectWith(peerID: MCPeerID) {}
    func didDisconnectWith(peerID: MCPeerID) {}
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .bet:
            // TODO: Add the bid of the player with peerID
            print("bet")
        case .fixBet:
            // TODO: Change the bid of the player with peerID
            print("fixBet")
        case .pickCards:
            // TODO: change the picked cards of the player with peerID
            print("pickCards")
        default:
            print("MessageType \(message.type) not allowed")
        }
    }
    
    
}
