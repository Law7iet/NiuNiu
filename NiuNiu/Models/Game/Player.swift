//
//  Player.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

import MultipeerConnectivity

class Player {
    
    // MARK: Properties
    var id: MCPeerID!
    var status: MessageEnum
    var points: Int
    var bid: Int
    var score: ScoreEnum {
        get {
            self.cards.score
        }
    }
    var cards: Cards
    
    // MARK: Methods
    init(id: MCPeerID, points: Int?) {
        self.id = id
        self.status = .none
        self.bid = 0
        self.points = points ?? 100
        self.cards = Cards(cards: [Card]())
    }
    
    func setCards(cards: [Card]) {
        self.cards.setCards(cards: cards)
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
    
}
