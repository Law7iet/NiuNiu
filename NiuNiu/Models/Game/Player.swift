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
    var score: ScoreEnum {
        get {
            if self.cards != nil {
                return self.cards!.score
            } else {
                return .none
            }
        }
    }
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
    
    // TODO: Which type in input?
    func pickCards() {
//        let index = 0
//        self.cards.pickCardAt(index: index)
    }
    
    func convertToUser() -> User {
        return User(player: self)
    }
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        return lhs.points < rhs.points
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id.displayName == rhs.id.displayName
    }
    
    func bet(amount: Int) {
        self.status = .bet
        self.bid = amount
        self.points -= amount
    }
    
    func check(amount: Int) {
        self.status = .check
        self.bid += amount
        self.points -= amount
    }
    
    func allIn() {
        self.status = .allIn
        self.bid += self.points
        self.points = 0
    }
    
    func pickCards(cards: Cards) {
        self.status = .cards
        // TODO: check cards are the same
        self.cards = cards
    }
}
