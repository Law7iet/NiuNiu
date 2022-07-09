//
//  GameEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

import Foundation

enum MessageType: Codable {
    case startGame
    case startMatch
    case startBet
    case confirmBet
    case chooseCard
    case endMatch
    case endGame
    
    case closeLobby
    case closeConnection
    
    case error
    case testMessage
}
