//
//  Message.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

import MultipeerConnectivity

class Message: Codable {
    
    var type: MessageEnum
    var amount: Int?
    var players: [Player]?
    
    init(_ type: MessageEnum) {
        self.type = type
    }
    
    init(_ type: MessageEnum, amount: Int) {
        self.type = type
        self.amount = amount
    }
    
    init(_ type: MessageEnum, players: [Player]) {
        self.type = type
        self.players = players
    }
    
    init(_ type: MessageEnum, amount: Int?, players: [Player]?) {
        self.type = type
        self.amount = amount
        self.players = players
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.amount = object!.amount
            self.players = object!.players
        } else {
            self.type = .error
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            self.type,
            amount: self.amount,
            players: self.players
        )
        return try? JSONEncoder().encode(object)
    }
    
}
