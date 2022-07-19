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
    var users: [User]?
    
    init(_ type: MessageEnum) {
        self.type = type
    }
    
    // Player data
    init(_ type: MessageEnum, users: [User]) {
        self.type = type
        self.users = users
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
    init(_ type: MessageEnum, amount: Int?, user: [User]?) {
        self.type = type
        self.amount = amount
        self.users = user
    }
    
    init(_ type: MessageEnum, cards: Cards?, amount: Int?, users: [User]?) {
        self.type = type
        self.cards = cards
        self.amount = amount
        self.users = users
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.cards = object!.cards
            self.amount = object!.amount
            self.users = object!.users
        } else {
            self.type = .error
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            self.type,
            cards: self.cards,
            amount: self.amount,
            users: self.users
        )
        return try? JSONEncoder().encode(object)
    }
    
}
