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
    var users: [User]?
    
    // MARK: Methods
    init(_ type: MessageType) {
        self.type = type
    }
    
    init(_ type: MessageType, amount: Int) {
        self.type = type
        self.amount = amount
    }
    
    init(_ type: MessageType, users: [User]) {
        self.type = type
        self.users = users
    }
    
    init(_ type: MessageType, amount: Int?, users: [User]?) {
        self.type = type
        self.amount = amount
        self.users = users
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.amount = object!.amount
            self.users = object!.users
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
            users: self.users
        )
        return try? JSONEncoder().encode(object)
    }
    
}
