//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

import UIKit

class Utils {
    static let timerShort = 5
    static let timerLong = 20
    static let points = 100
    
    static let borderWidth = CGFloat(5.0)
    static let cornerRadius = CGFloat(3.0)
    
    static func findPlayer(byName playerName: String, from players: [Player]) -> Player? {
        for player in players {
            if player.id.displayName == playerName {
                return player
            }
        }
        return nil
    }
    
    static func findUser(byName playerName: String, from users: [User]) -> User? {
        for user in users {
            if user.name == playerName {
                return user
            }
        }
        return nil
    }
    
}
