//
//  PlayerEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

enum PlayerEnum: Codable {

    // Players' status
    case bet
    case check
    case allIn
    case cards
    case fold
    case winner

    case none
    
    var description: String {
        switch self {
        case .bet: return "bet"
        case .check: return "check"
        case .allIn: return "allIn"
        case .cards: return "cards"
        case .fold: return "fold"
        case .winner: return "winner"
        case .none: return "none"
        }
    }
}
