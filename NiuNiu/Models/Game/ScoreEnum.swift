//
//  ScoreEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

enum ScoreEnum: Int, Codable, Comparable {

    case none = 0
    // No Niu
    case one = 1
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
    // Niu
    case niuOne = 21
    case niuTwo = 22
    case niuThree = 23
    case niuFour = 24
    case niuFive = 25
    case niuSix = 26
    case niuSeven = 27
    case niuEight = 28
    case niuNine = 29
    case niuNiu = 30

    static func < (lhs: ScoreEnum, rhs: ScoreEnum) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var description: String {
        switch self {
        case .none: return "None"
        case .one: return "One"
        case .two: return "Two"
        case .three: return "Three"
        case .four: return "Four"
        case .five: return "Five"
        case .six: return "Six"
        case .seven: return "Seven"
        case .eight: return "Eight"
        case .nine: return "Nine"
        case .ten: return "Ten"
        case .jack: return "Jack"
        case .queen: return "Queen"
        case .king: return "King"
        case .niuOne: return "NiuOne"
        case .niuTwo: return "NiuTwo"
        case .niuThree: return "NiuThree"
        case .niuFour: return "NiuFour"
        case .niuFive: return "NiuFive"
        case .niuSix: return "NiuSix"
        case .niuSeven: return "NiuSeven"
        case .niuEight: return "NiuEight"
        case .niuNine: return "NiuNine"
        case .niuNiu: return "NiuNiu"
        }
    }
    
}

