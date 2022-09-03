//
//  Player.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

import MultipeerConnectivity

protocol PlayerDelegate {
    func didDisconnect(with peerID: MCPeerID)
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data)
}

class Player: User {
    
    // MARK: Properties
    var client: Client!
    var gameDelegate: PlayerDelegate?
    
    // MARK: Methods
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setupClient(client: Client) {
        self.client = client
        self.client.gameDelegate = self
    }
    
    func setupPlayer(id: String, points: Int?) {
        self.setupUser(id: id, points: points)
    }
    
    func setupUser(_ user: User) {
        self.id = user.id
        self.status = user.status
        self.points = user.points
        self.bid = user.bid
        self.fixBid = user.fixBid
        self.cards = user.cards
        self.pickedCards = user.pickedCards
        self.numberOfPickedCards = user.numberOfPickedCards
        self.score = user.score
        self.wins = user.wins
        self.rounds = user.rounds
    }
}

extension Player: ClientGameDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        self.gameDelegate?.didDisconnect(with: peerID)
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        self.gameDelegate?.didReceiveMessage(from: peerID, messageData: messageData)
    }
    
}
