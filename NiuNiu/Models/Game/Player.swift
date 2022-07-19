//
//  Player.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

import MultipeerConnectivity

class Player: Comparable {
    
    // MARK: Properties
    var id: MCPeerID!
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
    init(id: MCPeerID, points: Int?) {
        self.id = id
        self.status = .none
        self.bid = 0
        self.points = points ?? 100
    }
    
    func setCards(cards: [Card]) {
        self.cards = Cards(elements: cards)
    }
    
    func setCards(cards: Cards?) {
        self.cards = cards
    }
    
    func bet(amount: Int) -> Bool {
        if amount > self.points {
            return false
        } else {
            self.bid = self.bid + amount
            return true
        }
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
    
}
