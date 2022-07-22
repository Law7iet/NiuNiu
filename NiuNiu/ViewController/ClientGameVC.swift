//
//  ClientGameVC.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ClientGameVC: UIViewController {

    // MARK: Properties
    var comms: Client!
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
        comms.clientDelegate = self
    }
    
    // MARK: Actions
    @IBAction func home(_ sender: Any) {
        let alert = UIAlertController(
            title: "Quit the game",
            message: "If you quit the game, you won't be able to play until the game ends. Are you sure to quit?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "No", style: .default)
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { action in
                self.comms.sendMessageToServer(message: Message(.closeSession))
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            })
        )
        self.present(alert, animated: true)
    }
    
    @IBAction func clickPlayer(_ sender: UIButton) {
        let user = User(name: sender.currentTitle!)
        self.comms.sendMessageToServer(message: Message(.reqPlayer, user: user))
    }
    
    @IBAction func bet(_ sender: Any) {
        self.himself.bid = self.bidValue
        self.comms.sendMessageToServer(message: Message(.bet, user: self.himself.convertToUser()))
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

    @IBAction func changeSliderValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.bidValue = currentValue
        self.bidLabel.text = "Your bid: \(currentValue) points"
    }
}

// MARK: LobbyManagerDelegate implementation
extension ClientGameVC: ClientDelegate {
    
    func didConnectWith(peerID: MCPeerID) {}
    
    func didDisconnectWith(peerID: MCPeerID) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Exit from game", message: "The game has been closed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            }))
            self.comms.disconnect()
            self.present(alert, animated: true)
        }
    }
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .startGame:
            print("startGame")
            let points = message.amount!
            self.himself = Player(id: self.comms.himselfPeerID, points: points)
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
            let user = message.user!
            DispatchQueue.main.async {
                self.statusLabel.text = "Match started!"
                for index in 0 ..< self.playersButton.count  {
                    let button = self.playersButton[index]
                    if button.isEnabled == false {
                        button.isEnabled = true
                        button.setTitle(user.name, for: UIControl.State.normal)
                        break
                    }
                }
            }
        case .resCards:
            print("ReceiveCards")
            let user = message.user!
            let cards = user.cards!
            self.himself.setCards(cards: cards)
            DispatchQueue.main.async {
                self.statusLabel.text = "Cards received!"
                for index in 0 ..< self.cardsButton.count {
                    let image = UIImage(named: cards.elements[index].getName())
                    self.cardsButton[index].setBackgroundImage(image, for: UIControl.State.normal)
                }
            }
        case .startBet:
            print("startBet")
            DispatchQueue.main.async {
                self.statusLabel.text = "Start Bet!"
                self.betButton.isEnabled = true
                self.bidSlider.isEnabled = true
            }
        case .stopBet:
            print("endBet")
            DispatchQueue.main.async {
                self.statusLabel.text = "Stop Bet!"
                self.betButton.isEnabled = false
                self.bidSlider.isEnabled = false
            }
            
        case .startCheck:
            print("startFixBet")
        case .stopCheck:
            print("endFixBet")
        case .startCards:
            print("startPickCards")
        case .stopCards:
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
            print("resPlayer")
            DispatchQueue.main.async {
                let user = message.user!
                let message = "Points: \(user.points)\nBid: \(user.bid)"
                let alert = UIAlertController(
                    title: user.name,
                    message: message,
                    preferredStyle: .actionSheet
                )
                alert.addAction(UIAlertAction(title: "Close", style: .default))
                self.present(alert, animated: true)
            }
            
        case .timer:
            print("timer")
            DispatchQueue.main.async {
                let time = message.amount!
                self.timerLabel.text = String(time)
            }
        // TODO: check if there're closeConnection or closeLobby
        default:
            print("ClientGameVC.didReceiveMessageFrom - message.type == \(message.type)")
        }
    }
    
}
