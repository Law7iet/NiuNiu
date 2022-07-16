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
    var isPlaying: Bool
    var points: Int
    var bid: Int
    var score: ScoreEnum
    var cards: [Card]
    var pickedCards: [Card]
    
    // MARK: Methods
    init(id: MCPeerID, points: Int?) {
        self.id = id
        self.isPlaying = true
        self.bid = 0
        self.points = points ?? 100
        self.cards = [Card]()
        self.pickedCards = [Card]()
        self.score = .one
    }
    
    func didBet() -> Bool {
        if self.bid > 0 {
            return true
        } else {
            return false
        }
    }
    
    func bet(amount: Int) -> Bool {
        if amount > self.points {
            return false
        } else {
            self.bid = self.bid + amount
            return true
        }
    }
    
}
