//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

import UIKit
import MultipeerConnectivity

class Utils {
    // Debug
    static let numberOfPlayers = 6
    static let pendingTimer = 2.5
    
    // Game setting
    static let timerOffset = 1
    static let timerShort = 3
    static let timerLong = 20
    static let points = 100
    
    // Card setting
    static let cornerRadius = CGFloat(5.0)
    static let cornerRadiusSmall = CGFloat(3.0)
    // borderWitdh it's equal to: 1.85% of the card's height
    static func borderWidth(withHeight height: CGFloat) -> CGFloat {
        return height * 1.85 / 100
    }

    static func findPlayer(byName playerName: String, from players: [Player]) -> Player? {
        for player in players {
            if player.id == playerName {
                return player
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
    
    static func getOneButtonAlert(title: String, message: String, action: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: action))
        return alert
    }
}
