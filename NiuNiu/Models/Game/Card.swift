//
//  Card.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

struct Card: Codable, Comparable, CustomStringConvertible {
    
    var rank: RankEnum
    var suit: SuitEnum
    
    var description: String {
        return "\(self.rank.rawValue) of \(self.suit.description)"
    }
    
    init(rank x: RankEnum, suit y: SuitEnum) {
        rank = x
        suit = y
    }
    
    func getName() -> String {
        var suit: String
        switch self.suit {
        case .hearts: suit = "hearts"
        case .diamonds: suit = "diamonds"
        case .clubs: suit = "clubs"
        case .spades: suit = "spades"
        }
        return "\(self.rank.rawValue)_of_\(suit)"
    }
    
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.rank.rawValue != rhs.rank.rawValue {
            return lhs.rank.rawValue < rhs.rank.rawValue
        } else {
            return lhs.suit.rawValue < rhs.suit.rawValue
        }
    }

}
