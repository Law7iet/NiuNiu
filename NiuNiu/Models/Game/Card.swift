//
//  Card.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

struct Card: Codable, Comparable, CustomStringConvertible {
    
    // MARK: Properties
    var rank: Rank
    var suit: Suit
    
    /// A string that describes the card value
    var description: String {
        return "\(self.rank.rawValue) of \(self.suit.description)"
    }
    
    /// The string used to get the card's image
    var fileName: String {
        return "\(self.rank.rawValue)_of_\(suit.description)"
    }
    
    // MARK: Methods
    init(rank x: Rank, suit y: Suit) {
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
