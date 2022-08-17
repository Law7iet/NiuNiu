//
//  Rank.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

enum Rank: Int, CaseIterable, Codable, Comparable {
    
    case ace = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    
    /// The integer value of the enum during the score calculation.
    var value: Int {
        switch self {
        case .ace: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 10
        case .queen: return 10
        case .king: return 10
        }
    }
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
}
