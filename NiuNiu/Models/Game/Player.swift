//
//  Player.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

import MultipeerConnectivity

class Player: Comparable, CustomStringConvertible {
    
    // MARK: Properties
    var id: MCPeerID!
    var status: PlayerEnum
    var isWinner: Bool
    var points: Int
    var bid: Int
    var cards: Cards?
    /// The player's score. It is calculated on the cards he picks
    var score: ScoreEnum {
        get {
            if self.cards != nil {
                return self.cards!.score
            } else {
                return .none
            }
        }
    }
    /// A string that describes all player's properties
    var description: String {
        var description = "Player: \(self.id.displayName)\n"
        description += "Status: \(self.status)\n"
        description += "Points: \(self.points)\n"
        description += "Bid: \(self.bid)\n"
        description += "Score: \(self.score)\n"
        description += "\(self.cards!)"
        return description
    }
    
    // MARK: Methods
    init(id: MCPeerID, points: Int?) {
        self.id = id
        self.status = .none
        self.bid = 0
        self.points = points ?? 100
        self.isWinner = false
    }
    
    func setCards(cards: [Card]) {
        self.cards = Cards(elements: cards)
    }
    
    func setCards(cards: Cards?) {
        self.cards = cards
    }
    
    func convertToUser() -> User {
        return User(player: self)
    }
    
    /// Change the player's status, bid and reduce his points
    /// - Parameter amount: the player bid
    func bet(amount: Int) {
        self.status = .bet
        self.bid = amount
        self.points -= amount
    }
    
    /// Change the player's status, increase his bid and reduce his points
    /// - Parameter amount: the amount to increase/decrease
    func check(amount: Int) {
        self.status = .check
        self.bid += amount
        self.points -= amount
    }
    
    /// Change the player's status, change his bid with his points and set to 0 his points
    func allIn() {
        self.status = .allIn
        self.bid += self.points
        self.points = 0
    }
    
    /// Change the player's status, and player.cards property with the argument.
    /// - Parameter cards: the cards.
    func pickCards(cards: Cards) {
        self.status = .cards
        self.cards = cards
    }
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        return lhs.points < rhs.points
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id.displayName == rhs.id.displayName
    }
}
