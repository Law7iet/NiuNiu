//
//  RankEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

enum RankEnum: Int, CaseIterable, Codable {
    
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

    var description: String {
        switch self {
        case .ace: return "ace"
        case .two: return "two"
        case .three: return "three"
        case .four: return "four"
        case .five: return "five"
        case .six: return "six"
        case .seven: return "seven"
        case .eight: return "eight"
        case .nine: return "nine"
        case .ten: return "ten"
        case .jack: return "jack"
        case .queen: return "queen"
        case .king: return "king"
        }
    }
    
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
    
}
