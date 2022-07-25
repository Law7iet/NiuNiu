//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

import UIKit
import MultipeerConnectivity

class Utils {
    static let timerShort = 3
    static let timerLong = 20
    static let points = 100
    
    static let cornerRadius = CGFloat(5.0)
    // borderWitdh it's equal to: 0.0185% of the card's height
    static func borderWidth(withHeight height: CGFloat) -> CGFloat {
        return height * 0.0185 / 100
    }
    
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
    
    static func getNames(fromPeerIDs peerIDs: [MCPeerID]) -> [String] {
        var array = [String]()
        for peerID in peerIDs {
            array.append(peerID.displayName)
        }
        return array
    }
}
