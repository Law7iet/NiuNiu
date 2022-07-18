//
//  GameMessage.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

import Foundation
import MultipeerConnectivity

class Message: Codable {
    
    var type: MessageEnum
    var cards: Cards?
    var amount: Int?
    var user: User?
    
    init(_ type: MessageEnum) {
        self.type = type
    }
    
    // Player
    init(_ type: MessageEnum, user: User?) {
        self.type = type
        self.user = user
    }
    
    // Send cards to clients
    init(_ type: MessageEnum, cards: Cards) {
        self.type = type
        self.cards = cards
    }
    
    // Bet and fixBid
    init(_ type: MessageEnum, amount: Int?) {
        self.type = type
        self.amount = amount
    }
    
    // Winner
    init(_ type: MessageEnum, amount: Int?, user: User?) {
        self.type = type
        self.amount = amount
        self.user = user
    }
    
    init(_ type: MessageEnum, cards: Cards?, amount: Int?, user: User?) {
        self.type = type
        self.cards = cards
        self.amount = amount
        self.user = user
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.cards = object!.cards
            self.amount = object!.amount
            self.user = object!.user
        } else {
            self.type = .error
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            self.type,
            cards: self.cards,
            amount: self.amount,
            user: self.user
        )
        return try? JSONEncoder().encode(object)
    }
    
}
