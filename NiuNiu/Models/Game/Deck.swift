//
//  Deck.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

class Deck {
    
    // Properties
    var cards: [Card]
    
    // Methods
    init() {
        // Deck
        self.cards = [Card]()
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }
    
    /// Shuffle the deck.
    func shuffle() {
        self.cards.shuffle()
    }
    
    /// Returns 5 cards form the deck.
    /// - Returns: The 5 cards.
    func getCards() -> [Card] {
        var myCards = [Card]()
        for _ in 1...5 {
            myCards.append(self.cards.removeFirst())
        }
        return myCards
    }
    
}
