//
//  SuitEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

enum SuitEnum: Int, CaseIterable, Codable, Comparable {
    
    case hearts = 1
    case diamonds = 2
    case clubs = 3
    case spades = 4
    
    /// A string that describes the suit value
    var description: String {
        switch self {
        case .hearts: return "hearts"
        case .diamonds: return "diamonds"
        case .clubs: return "clubs"
        case .spades: return "spades"
        }
    }
    
    static func < (lhs: SuitEnum, rhs: SuitEnum) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
}
