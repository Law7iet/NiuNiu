//
//  GameEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 06/07/22.
//

import Foundation

enum MessageEnum: Codable {
    
    case startGame
    case startMatch
    case receiveCards // [Cards]
    case startBet // Int
    case bet
    case endBet
    case startFixBet // Int
    case fixBet
    case endFixBet
    case startPickCards // Int
    case pickCards
    case endPickCards
    case showCards
    case declareWinner // Int
    case endMatch
    case endGame
    
    case closeLobby
    case closeConnection
    
    case timer
    
    case error
    case test
}
