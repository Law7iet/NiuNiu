//
//  User.swift
//  NiuNiu
//
//  Created by Han Chu on 18/07/22.
//

import MultipeerConnectivity

/// A class that rapresents the Player class.
/// This class is used to pass the player's information between devices.
/// It doesn't have any "set" methods
class User: Codable {
    
    // MARK: Properties
    var name: String
    var status: PlayerEnum
    var points: Int
    var bid: Int
    var cards: [Card]
    var pickedCards: [Bool]
    var numberOfPickedCards: Int
    var tieBreakerCard: Card?
    var score: ScoreEnum
    
    // MARK: Methods
    init(player: Player) {
        self.name = player.id.displayName
        self.status = player.status
        self.points = player.points
        self.bid = player.bid
        self.cards = player.cards
        self.pickedCards = player.pickedCards
        self.numberOfPickedCards = player.numberOfPickedCards
        self.tieBreakerCard = player.tieBreakerCard
        self.score = player.score
    }
    
    func convertToPlayer(withPeerID peerID: MCPeerID) -> Player {
        let player = Player(id: peerID, points: self.points)
        player.status = self.status
        player.points = self.points
        player.bid = self.bid
        player.cards = self.cards
        player.pickedCards = self.pickedCards
        player.numberOfPickedCards = self.numberOfPickedCards
        player.tieBreakerCard = self.tieBreakerCard
        player.score = self.score
        return player
    }
    
}
