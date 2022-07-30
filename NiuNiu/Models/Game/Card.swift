//
//  Card.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

struct Card: Codable, Comparable, CustomStringConvertible {
    
    var rank: RankEnum
    var suit: SuitEnum
    
    /// A string that describes the card value
    var description: String {
        return "\(self.rank.rawValue) of \(self.suit.description)"
    }
    
    /// The string used to get the card's image
    var fileName: String {
        return "\(self.rank.rawValue)_of_\(suit.description)"
    }
    
    init(rank x: RankEnum, suit y: SuitEnum) {
        rank = x
        suit = y
    }
        
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.rank.rawValue != rhs.rank.rawValue {
            return lhs.rank < rhs.rank
        } else {
            return lhs.suit < rhs.suit
        }
    }

}
