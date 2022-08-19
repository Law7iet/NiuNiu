//
//  Deck.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

class Deck {
    
    // MARK: Properties
    var cards: [Card]
    
    // MARK: Methods
    init() {
        // Deck
        self.cards = [Card]()
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        self.cards.shuffle()
    }
        
    /// Returns 5 cards form the deck.
    /// - Returns: The 5 cards.
    func getFiveCards() -> [Card] {
        var myCards = [Card]()
        for _ in 1...5 {
            myCards.append(self.cards.removeFirst())
        }
        return myCards
    }
    
}
