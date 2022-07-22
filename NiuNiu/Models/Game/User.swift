//
//  User.swift
//  NiuNiu
//
//  Created by Han Chu on 18/07/22.
//

import MultipeerConnectivity

/// A class that rapresents the Player class.
/// This class is used to pass the player's information between devices.
class User: Codable {
    
    // MARK: Properties
    var name: String
    var status: PlayerEnum
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
    var isWinner: Bool
    
    // MARK: Methods
    init(player: Player) {
        self.name = player.id.displayName
        self.status = player.status
        self.cards = player.cards
        self.points = player.points
        self.bid = player.bid
        self.isWinner = player.isWinner
    }
    
    init(name: String) {
        self.name = name
        self.status = .none
        self.points = 0
        self.bid = 0
        self.isWinner = false
    }
    
    func convertToPlayer(withPeerID peerID: MCPeerID) -> Player {
        let player = Player(id: peerID, points: self.points)
        player.setCards(cards: self.cards)
        player.bid = self.bid
        player.status = self.status
        player.isWinner = self.isWinner
        return player
    }
    
}
