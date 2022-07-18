//
//  User.swift
//  NiuNiu
//
//  Created by Han Chu on 18/07/22.
//

/// A class that rapresents the Player class.
/// This class is used to pass the player's information between devices.
class User: Codable {
    
    // MARK: Properties
    var name: String
    var status: MessageEnum
    var points: Int
    var cards: Cards?
    var bid: Int
    var score: ScoreEnum {
        get {
            if self.cards != nil {
                return self.cards!.score
            } else {
                return .none
            }
        }
    }
    
    // MARK: Methods
    init(player: Player) {
        self.name = player.id.displayName
        self.status = player.status
        self.cards = player.cards
        self.points = player.points
        self.bid = player.bid
    }
    
}
