//
//  Cards.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

class Cards {
    var cards: [Card]
    var isPicked: [Bool]
    var numberOfPickedCards: Int
    
    init() {
        self.cards = [Card]()
        self.isPicked = [false, false, false, false, false]
        self.numberOfPickedCards = 0
    }
    
    func setCards(cards: [Card]) {
        self.cards = cards
    }
    
    func pickCardAt(index: Int) {
        if self.isPicked[index] == false {
            self.isPicked[index] = true
            self.numberOfPickedCards = self.numberOfPickedCards + 1
        } else {
            self.isPicked[index] = false
            self.numberOfPickedCards = self.numberOfPickedCards - 1
        }
    }
    
    func score() -> ScoreEnum {
        if self.numberOfPickedCards == 1 {
            // No Niu
            let index = self.isPicked.firstIndex(of: true)!
            return ScoreEnum(rawValue: self.cards[index].rank.rawValue)!
        } else if self.numberOfPickedCards == 3 {
            // Niu
            var totalThree = 0
            var totalTwo = 0
            for index in 0...4 {
                if self.isPicked[index] == true {
                    totalThree = totalThree + self.cards[index].rank.rawValue
                } else {
                    totalTwo = totalTwo + self.cards[index].rank.rawValue
                }
            }
            if totalThree % 10 == 0 {
                // Compute the remain 2 cards
                return ScoreEnum(rawValue: (totalTwo % 10) + 10)!
            } else {
                // Error: picked cards not allowed
                return .none
            }
        } else {
            // Error: picked an illegal numbers of cards
            return .none
        }
    }
    
}
