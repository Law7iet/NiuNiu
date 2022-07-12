//
//  GameMessage.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

import Foundation

class Message: Codable {
    
    var type: MessageEnum
    var text: String?
    var cards: [Card]?
    
    init(type: MessageEnum, text: String?, cards: [Card]?) {
        self.type = type
        self.text = text
        self.cards = cards
    }
    
    init(type: MessageEnum) {
        self.type = type
        self.text = nil
        self.cards = nil
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.text = object!.text
            self.cards = object!.cards
        } else {
            self.type = .error
            self.text = nil
            self.cards = nil
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            type: self.type,
            text: self.text,
            cards: self.cards
        )
        return try? JSONEncoder().encode(object)
    }
    
}
