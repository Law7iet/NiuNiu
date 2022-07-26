//
//  SuitEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

enum SuitEnum: Int, CaseIterable, Codable {
    
    case hearts = 4
    case diamonds = 3
    case clubs = 2
    case spades = 1
    
    var description: String {
        switch self {
        case .hearts: return "♥️"
        case .diamonds: return "♦️"
        case .clubs: return "♣️"
        case .spades: return "♠️"
        }
    }
    
}
