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
    case resCards
    case startBet
    case stopBet
    case startFixBid
    case stopFixBid
    case startCards
    case stopCards
    case showCards
    case winner
    case endMatch
    case endGame
    
    // Game utility
    case timer
    case resPlayer
    case fold
    
    // Connections
    case closeLobby
    case closeSession

    // MARK: Send from client
    // Game actions
    case bet
    case fixBid
    case cards
    case reqPlayer
    
    // MARK: Other
    case none
    case error
    case test
}
