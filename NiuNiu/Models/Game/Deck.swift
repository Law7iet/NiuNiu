//
//  Deck.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

class Deck {
    
    var cards: [Card]
    
    init() {
        // Deck
        self.cards = [Card]()
        for suit in SuitEnum.allCases {
            for rank in RankEnum.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }
    
    func shuffle() {
        self.cards.shuffle()
    }
    
    func getCards() -> [Card] {
        var myCards = [Card]()
        for _ in 1...5 {
            myCards.append(self.cards.removeFirst())
        }
        return myCards
    }
    
}
