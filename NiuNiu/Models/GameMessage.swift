//
//  GameMessage.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

class GameMessage {
    var type: GameEnum
    var message: String?
    var cards: [Card]?
    
    init(type: GameEnum, message: String?, cards: [Card]?) {
        self.type = type
        self.message = message
        self.cards = cards
    }
}
