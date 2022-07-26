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
    
    func getRankAsString() -> String {
        return String(self.rank.rawValue)
    }
    
    func getSuitAsString() -> String {
        switch suit {
        case .hearts:
            return "hearts"
        case .diamonds:
            return "diamonds"
        case .clubs:
            return "clubs"
        case .spades:
            return "spades"
        }
    }
    
    func getName() -> String {
        return "\(self.getRankAsString())_of_\(self.getSuitAsString())"
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
