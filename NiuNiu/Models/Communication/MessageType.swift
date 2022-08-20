//
//  MessageType.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

enum MessageType: Codable {
    
    // MARK: Send from server
    // Game status
    case startMatch
    case startBet
    case stopBet
    case startCheck
    case stopCheck
    case startCards
    case stopCards
    case endMatch
    
    // Game utility
    case maxPlayers
    case resPlayer
    case notify
    
    // Connections
    case startGames
    case closeSession

    // MARK: Send from client
    // Player actions
    case bet
    case check
    case cards
    case fold
    case reqPlayer
    
    // MARK: Other
    case none
    case error
    case test
    
}
