//
//  Dealer.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

import MultipeerConnectivity

class Player {
    
    var id: MCPeerID!
    
    func setCards(_ cards: [Card]) {}
    func chooseCard(_ card: Card) {}
    func bet(amout: Int) {}
    
}

class Dealer {
    
    func shuffleCards() {}
    func getCards() -> [Card] { return [Card]() }
    func reciveBidFrom(user peerID: MCPeerID) {}
    
}
