//
//  Message.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

import MultipeerConnectivity

class Message: Codable {
    
    // MARK: Properties
    var type: MessageType
    var amount: Int?
    var players: [Player]?
    
    // MARK: Methods
    init(_ type: MessageType) {
        self.type = type
    }
    
    init(_ type: MessageType, amount: Int) {
        self.type = type
        self.amount = amount
    }
    
    init(_ type: MessageType, players: [Player]) {
        self.type = type
        self.players = players
    }
    
    init(_ type: MessageType, amount: Int?, players: [Player]?) {
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
    
    /// Convert the message to `Data`.
    /// - Returns: the message in `Data` type.
    func convertToData() -> Data? {
        let object = Message(
            self.type,
            amount: self.amount,
            players: self.players
        )
        return try? JSONEncoder().encode(object)
    }
    
}
