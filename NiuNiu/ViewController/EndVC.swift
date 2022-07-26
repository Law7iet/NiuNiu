//
//  EndViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 23/07/22.
//

import UIKit

class EndVC: UIViewController {

    // MARK: Properties
    var dealer: Dealer?
    var client: Client!
    var users: [User]!
    var prize: Int!
    
    @IBOutlet weak var winnerID: UILabel!
    @IBOutlet weak var winnerPoints: UILabel!
    @IBOutlet weak var winnerScore: UILabel!
    @IBOutlet var winnerCards: [UIButton]!
    
    @IBOutlet var playerIDs: [UILabel]!
    @IBOutlet var playerPoints: [UILabel]!
    @IBOutlet var playerScore: [UILabel]!
    
    @IBOutlet var cards1: [UIButton]!
    @IBOutlet var cards2: [UIButton]!
    @IBOutlet var cards3: [UIButton]!
    @IBOutlet var cards4: [UIButton]!
    @IBOutlet var cards5: [UIButton]!
    lazy var playerCards = [cards1, cards2, cards3, cards4, cards5]
    
    // MARK: Supporting functions
    func setupCard(buttons: [UIButton], cards: Cards) {
        var cardTrueIndex = 0
        var cardFalseIndex = 4
        for cardIndex in 0 ... 4 {
            let image = UIImage(named: cards[cardIndex].getName())
            if cards.chosenCards[cardIndex] == true {
                buttons[cardTrueIndex].setBackgroundImage(image, for: UIControl.State.normal)
                buttons[cardTrueIndex].layer.cornerRadius = Utils.cornerRadius
                buttons[cardTrueIndex].layer.borderWidth = Utils.borderWidth(withHeight: buttons[0].frame.height)
                buttons[cardTrueIndex].layer.borderColor = UIColor.red.cgColor
                cardTrueIndex += 1
            } else {
                buttons[cardFalseIndex].setBackgroundImage(image, for: UIControl.State.normal)
                cardFalseIndex -= 1
            }
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup users
        if self.dealer != nil {
            self.users = [User]()
            for player in self.dealer!.players.elements {
                self.users?.append(player.convertToUser())
            }
        }
        // Make graphics
        var userIndex = 0
        for user in self.users! {
            if user.status == .winner {
                // Manage the winner
                self.winnerID.text = user.name
                self.winnerPoints.text = "Points: \(user.points - self.prize) + \(self.prize!)"
                self.winnerScore.text = user.score.description
                self.setupCard(buttons: self.winnerCards, cards: user.cards!)
            } else {
                self.playerIDs[userIndex].text = user.name
                self.playerPoints[userIndex].text = "Points: \(user.points)"
                self.playerScore[userIndex].text = user.score.description
                self.setupCard(buttons: self.playerCards[userIndex]!, cards: user.cards!)
                userIndex += 1
            }
        }
    }
    
    // MARK: Actions
    @IBAction func quit(_ sender: Any) {
        let message = self.dealer != nil ? "If you quit the game, the game will end. Are you sure to quit?" : "If you quit the game, you won't be able to play until the game ends. Are you sure to quit?"
        let alert = UIAlertController(
            title: "Quit the game",
            message: message,
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
                // Notify and exit or close
                if self.dealer != nil {
                    self.dealer?.server.sendMessage(to: self.dealer!.server.clientsPeerIDs, message: Message(.closeLobby))
                } else {
                    self.client.sendMessageToServer(message: Message(.closeSession))
                }
                self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
            }
        ))
        self.present(alert, animated: true)
    }
    

}
