//
//  PlayerStatus.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

enum PlayerStatus: Codable {

    case bet
    case check
    case allIn
    case cards
    
    case didBet
    case didCheck
    case didCards
    
    case fold
    case disconnected
    case winner
    case none
    
    /// A string that describes the player enum
    var description: String {
        switch self {
        case .bet: return "bet"
        case .check: return "check"
        case .allIn: return "allIn"
        case .cards: return "cards"
        case .didBet: return "didBet"
        case .didCheck: return "didCheck"
        case .didCards: return "didCards"
        case .fold: return "fold"
        case .disconnected: return "disconnected"
        case .winner: return "winner"
        case .none: return "none"
        }
    }

}
