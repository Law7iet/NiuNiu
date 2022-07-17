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
    var player: String?
    
    init(type: MessageEnum) {
        self.type = type
    }

    init(type: MessageEnum, cards: Cards) {
        self.type = type
        self.cards = cards
    }
    
    init(type: MessageEnum, amount: Int?) {
        self.type = type
        self.amount = amount
    }
    
    init(type: MessageEnum, amount: Int?, player: String?) {
        self.type = type
        self.amount = amount
        self.player = player
    }
    
    init(type: MessageEnum, cards: Cards?, amount: Int?, player: String?) {
        self.type = type
        self.cards = cards
        self.amount = amount
        self.player = player
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.cards = object!.cards
            self.amount = object!.amount
            self.player = object!.player
        } else {
            self.type = .error
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            type: self.type,
            cards: self.cards,
            amount: self.amount,
            player: self.player
        )
        return try? JSONEncoder().encode(object)
    }
    
}
