//
//  Card.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

struct Card: Codable {
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
        }
    }
}
