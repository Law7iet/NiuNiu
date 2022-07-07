//
//  Player.swift
//  NiuNiu
//
//  Created by Han Chu on 07/07/22.
//

class Player {
    var name: String
    var points: Int
    var cards: [Card]
    var bid: Int
    
    init(name: String) {
        self.name = name
        self.points = 100
        self.bid = 0
        self.cards = [Card]()
    }
    
    func bet(points: Int) -> Bool {
        if points > self.points || points < 0
        {
            return false
        }
        else
        {
            self.bid = bid + points
            return true
        }
    }
    
    func addCard(card: Card) {
        self.cards.append(card)
    }
    
    func getCard(atIndex index: Int) -> Card {
        return self.cards[index]
    }
    
    func removeCards() {
        self.cards.removeAll()
    }
    
    func showCards() {
        for card in cards {
            print(card.getRankAsString() + " di " + card.getSuitAsString())
        }
    }
}
