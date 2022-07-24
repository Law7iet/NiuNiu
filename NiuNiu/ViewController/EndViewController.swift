//
//  EndViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 23/07/22.
//

import UIKit

class EndViewController: UIViewController {

    var himself: Player?
    var server: Dealer?
    var client: Client?
    var users: [User]?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup users
        if self.server != nil {
            self.users = [User]()
            for player in [self.server!.himself] + self.server!.players.elements {
                self.users?.append(player.convertToUser())
            }
        }
        // Binding to UI
        var userIndex = 0
        var cardNewIndex: Int
        for user in self.users! {
            if user.isWinner == true {
                self.winnerID.text = user.name
                self.winnerPoints.text = "Points: \(user.points - self.prize) + \(self.prize!)"
                self.winnerScore.text = user.score.description
                cardNewIndex = 0
                for cardOldIndex in 0 ... 4 {
                    if user.cards!.chosenCards[cardOldIndex] == true {
                        let image = UIImage(named: user.cards![cardOldIndex].getName())
                        self.winnerCards[cardNewIndex].setBackgroundImage(image, for: UIControl.State.normal)
                        self.winnerCards[cardNewIndex].layer.cornerRadius = Utils.cornerRadius
                        self.winnerCards[cardNewIndex].layer.borderWidth = Utils.borderWidth(withHeight: self.winnerCards[0].frame.height)
                        self.winnerCards[cardNewIndex].layer.borderColor = UIColor.red.cgColor
                        cardNewIndex += 1
                    } else {
                        let image = UIImage(named: user.cards![cardOldIndex].getName())
                        self.winnerCards[4 - cardNewIndex].setBackgroundImage(image, for: UIControl.State.normal)
                        self.winnerCards[4 - cardNewIndex].layer.cornerRadius = Utils.cornerRadius
                        self.winnerCards[4 - cardNewIndex].layer.borderWidth = self.winnerCards[0].frame.height * 3 / 162
                        self.winnerCards[4 - cardNewIndex].layer.borderColor = UIColor.red.cgColor
                    }
                }
            } else {
                self.playerIDs[userIndex].text = user.name
                self.playerPoints[userIndex].text = "Points: \(user.points)"
                self.playerScore[userIndex].text = user.score.description
                cardNewIndex = 0
                for cardOldIndex in 0 ... 4 {
                    if user.cards!.chosenCards[cardOldIndex] == true {
                        let image = UIImage(named: user.cards![cardOldIndex].getName())
                        self.playerCards[userIndex]![cardNewIndex].setBackgroundImage(image, for: UIControl.State.normal)
                        self.playerCards[userIndex]![cardNewIndex].layer.cornerRadius = Utils.cornerRadius
                        self.playerCards[userIndex]![cardNewIndex].layer.borderWidth = Utils.borderWidth(withHeight: self.playerCards[0]![0].frame.height)
                        self.playerCards[userIndex]![cardNewIndex].layer.borderColor = UIColor.red.cgColor
                        cardNewIndex += 1
                    } else {
                        let image = UIImage(named: user.cards![cardOldIndex].getName())
                        self.playerCards[userIndex]![4 - cardNewIndex].setBackgroundImage(image, for: UIControl.State.normal)
                        self.playerCards[userIndex]![4 - cardNewIndex].layer.cornerRadius = Utils.cornerRadius
                        self.playerCards[userIndex]![4 - cardNewIndex].layer.borderWidth = Utils.borderWidth(withHeight: self.playerCards[0]![0].frame.height)
                        self.playerCards[userIndex]![4 - cardNewIndex].layer.borderColor = UIColor.red.cgColor
                    }
                }
                userIndex += 1
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
