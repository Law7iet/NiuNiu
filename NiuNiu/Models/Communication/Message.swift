//
//  GameMessage.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

import Foundation

class Message: Codable {
    
    var type: MessageEnum
    var cards: [Card]?
    var amount: Int?
    
    init(type: MessageEnum) {
        self.type = type
        self.cards = nil
        self.amount = nil
    }

    init(type: MessageEnum, cards: [Card]?) {
        self.type = type
        self.cards = cards
        self.amount = nil
    }
    
    init(type: MessageEnum, amount: Int?) {
        self.type = type
        self.amount = amount
        self.cards = nil
    }
    
    init(type: MessageEnum, cards: [Card]?, amount: Int?) {
        self.type = type
        self.cards = cards
        self.amount = amount
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.cards = object!.cards
            self.amount = object!.amount
        } else {
            self.type = .error
            self.cards = nil
            self.amount = nil
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            type: self.type,
            cards: self.cards,
            amount: self.amount
        )
        return try? JSONEncoder().encode(object)
    }
    
}
