//
//  Cards.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

class Cards: Codable {
    
    var elements: [Card]
    var chosenCards: [Bool]
    var numberOfPickedCards: Int
    var score: ScoreEnum
    var tieBreakerCard: Card?
    
    init(elements: [Card]) {
        self.elements = elements
        self.chosenCards = [false, false, false, false, false]
        self.numberOfPickedCards = 0
        self.score = .none
    }
    
    func pickCardAt(index: Int) {
        // Card
        if self.chosenCards[index] == false {
            self.chosenCards[index] = true
            self.numberOfPickedCards = self.numberOfPickedCards + 1
        } else {
            self.chosenCards[index] = false
            self.numberOfPickedCards = self.numberOfPickedCards - 1
        }
        // Score and tie-breaker card
        if self.numberOfPickedCards == 1 {
            // No Niu
            let index = self.chosenCards.firstIndex(of: true)!
            self.score = ScoreEnum(rawValue: self.elements[index].rank.rawValue)!
            self.tieBreakerCard = self.elements[index]
        } else if self.numberOfPickedCards == 3 {
            // Niu
            var totalThree = 0
            var totalTwo = 0
            for index in 0...4 {
                if self.chosenCards[index] == true {
                    totalThree = totalThree + self.elements[index].rank.rawValue
                } else {
                    totalTwo = totalTwo + self.elements[index].rank.rawValue
                    // Compute the tie-breaker card
                    if self.tieBreakerCard == nil {
                        self.tieBreakerCard = self.elements[index]
                    } else {
                        if self.tieBreakerCard! < self.elements[index] {
                            self.tieBreakerCard = self.elements[index]
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
