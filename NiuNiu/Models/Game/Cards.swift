//
//  Cards.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

class Cards: Codable, CustomStringConvertible {
    
    var elements: [Card]
    var chosenCards: [Bool]
    var numberOfPickedCards: Int
    var score: ScoreEnum
    var tieBreakerCard: Card?
    var description: String {
        var description = ""
        for index in 0 ... 4 {
            if self.chosenCards[index] == true {
                description = "- [\(self.elements[index].description)]\n" + description
            } else {
                description = description + "- \(self.elements[index].description)\n"
            }
        }
        return "Cards:\n" + description
    }
    
    init(elements: [Card]) {
        self.elements = elements
        self.chosenCards = [false, false, false, false, false]
        self.numberOfPickedCards = 0
        self.score = .none
    }
    
    subscript(index: Int) -> Card {
        return self.elements[index]
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
            let index = self.chosenCards.firstIndex(of: true)!
            // Score and tie-breaker card
            self.score = ScoreEnum(rawValue: self.elements[index].rank.value)!
            self.tieBreakerCard = self.elements[index]
        } else if self.numberOfPickedCards == 3 {
            var totalThree = 0
            var totalTwo = 0
            for index in 0...4 {
                if self.chosenCards[index] == true {
                    // Picked cards sum
                    totalThree = totalThree + self.elements[index].rank.value
                } else {
                    // Not picked cards sum
                    totalTwo = totalTwo + self.elements[index].rank.value
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
            // Check if the picked cards are correct
            if totalThree % 10 == 0 {
                // Compute the remain 2 cards
                if totalTwo % 10 == 0 {
                    self.score = .niuNiu
                } else {
                    self.score =  ScoreEnum(rawValue: ((totalTwo % 10) + 20))!
                }
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
