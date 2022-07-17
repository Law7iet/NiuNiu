//
//  GameEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

enum MessageEnum: Codable {
    
    // Send from server
    case startGame
    case startMatch
    case receiveCards
    case startBet
    case endBet
    case startFixBid
    case endFixBid
    case startChooseCards
    case endChooseCards
    case showCards
    case winner
    case endMatch
    case endGame
    
    // Connections
    case closeLobby
    case closeConnection
    
    // Game utility
    case timer
    case fold

    // Send from client
    case bet
    case fixBid
    case chooseCards

    // Other
    case none
    case error
    case test
}
