//
//  Card.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

struct Card: Codable, Comparable {
    
    var rank: RankEnum
    var suit: SuitEnum
    
    init(rank x: RankEnum, suit y: SuitEnum) {
        rank = x
        suit = y
    }
    
    func getRankAsString() -> String {
        return String(self.rank.rawValue)
    }
    
    func getSuitAsString() -> String {
        switch suit {
        case .hearts:
            return "cuori"
        case .diamonds:
            return "quadri"
        case .clubs:
            return "fiori"
        case .spades:
            return "picche"
        default:
            return "nil"
        }
    }
    
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.rank.rawValue != rhs.rank.rawValue {
            return lhs.rank.rawValue < rhs.rank.rawValue
        } else {
            // Equal rank value
            return lhs.suit.rawValue < rhs.suit.rawValue
        }
    }

}
