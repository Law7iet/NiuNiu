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
    var user: User?
    
    init(_ type: MessageEnum) {
        self.type = type
    }
    
    init(_ type: MessageEnum, amount: Int) {
        self.type = type
        self.amount = amount
    }
    
    init(_ type: MessageEnum, user: User) {
        self.type = type
        self.user = user
    }
    
    init(_ type: MessageEnum, amount: Int, user: User) {
        self.type = type
        self.amount = amount
        self.user = user
    }
    
    init(_ type: MessageEnum, amount: Int?, user: User?) {
        self.type = type
        self.amount = amount
        self.user = user
    }
    
    init(data: Data) {
        let object: Message? = try? JSONDecoder().decode(Message.self, from: data)
        if object != nil {
            self.type = object!.type
            self.amount = object!.amount
            self.user = object!.user
        } else {
            self.type = .error
        }
    }
    
    func convertToData() -> Data? {
        let object = Message(
            self.type,
            amount: self.amount,
            user: self.user
        )
        return try? JSONEncoder().encode(object)
    }
    
}
