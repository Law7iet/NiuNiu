//
//  GameEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

enum MessageEnum: Codable {
    
    // MARK: Send from server
    // Game status
    case startGame
    case startMatch
    case startBet
    case stopBet
    case startCheck
    case stopCheck
    case startCards
    case stopCards
    case endMatch
    case endGame

    // Game utility
    case timer
    case resPlayer
    
    // Connections
//    case closeLobby
    case closeSession

    // MARK: Send from client
    // Game actions
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
