//
//  Cards.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

class Cards: Codable {
    var cards: [Card]
    var isPicked: [Bool]
    var numberOfPickedCards: Int
    var score: ScoreEnum
    var tieBreakerCard: Card?
    
    init(cards: [Card]) {
        self.cards = cards
        self.isPicked = [false, false, false, false, false]
        self.numberOfPickedCards = 0
        self.score = .none
    }
    
    func setCards(cards: [Card]) {
        self.cards = cards
    }
    
    func pickCardAt(index: Int) {
        // Card
        if self.isPicked[index] == false {
            self.isPicked[index] = true
            self.numberOfPickedCards = self.numberOfPickedCards + 1
        } else {
            self.isPicked[index] = false
            self.numberOfPickedCards = self.numberOfPickedCards - 1
        }
        // Score and tie-breaker card
        if self.numberOfPickedCards == 1 {
            // No Niu
            let index = self.isPicked.firstIndex(of: true)!
            self.score = ScoreEnum(rawValue: self.cards[index].rank.rawValue)!
            self.tieBreakerCard = self.cards[index]
        } else if self.numberOfPickedCards == 3 {
            // Niu
            var totalThree = 0
            var totalTwo = 0
            for index in 0...4 {
                if self.isPicked[index] == true {
                    totalThree = totalThree + self.cards[index].rank.rawValue
                } else {
                    totalTwo = totalTwo + self.cards[index].rank.rawValue
                    // Compute the tie-breaker card
                    if self.tieBreakerCard == nil {
                        self.tieBreakerCard = self.cards[index]
                    } else {
                        if self.tieBreakerCard! < self.cards[index] {
                            self.tieBreakerCard = self.cards[index]
                        }
                    }
                }
            }
            if totalThree % 10 == 0 {
                // Compute the remain 2 cards
                self.score =  ScoreEnum(rawValue: (totalTwo % 10) + 10)!
            } else {
                // Error: picked cards not allowed
                self.score = .none
                self.tieBreakerCard = nil
            }
        } else {
            // Error: picked an illegal numbers of cards
            self.score = .none
            self.tieBreakerCard = nil
        }
    }
    
}
