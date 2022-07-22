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
    var users: [User]?
    
    init(_ type: MessageEnum) {
        self.type = type
    }
    
    init(_ type: MessageEnum, amount: Int) {
        self.type = type
        self.amount = amount
    }
    
    init(_ type: MessageEnum, users: [User]) {
        self.type = type
        self.users = users
    }
    
    init(_ type: MessageEnum, amount: Int?, users: [User]?) {
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
    
    func convertToData() -> Data? {
        let object = Message(
            self.type,
            amount: self.amount,
            users: self.users
        )
        return try? JSONEncoder().encode(object)
    }
    
}
