//
//  User.swift
//  NiuNiu
//
//  Created by Han Chu on 03/09/22.
//

class User: Codable, Comparable, CustomStringConvertible {
    
    // MARK: Properties
    var id: String
    var status: PlayerStatus
    var points: Int
    var bid: Int
    var fixBid: Int
    var cards: [Card]
    var pickedCards: [Bool]
    var numberOfPickedCards: Int
    var tieBreakerCard: Card?
    var score: Score
    var wins: Int
    var rounds: Int
    
    /// A string that describes the player.
    var description: String {
        var cardsDescription = ""
        if !self.cards.isEmpty {
            for index in 0 ... 4 {
                if self.pickedCards[index] == true {
                    cardsDescription = "- [\(self.cards[index].description)]\n" + cardsDescription
                } else {
                    cardsDescription = cardsDescription + "- \(self.cards[index].description)\n"
                }
            }
        }
        
        var description = ""
        description += "Player: \(self.id)\n"
        description += "Status: \(self.status)\n"
        description += "Points: \(self.points)\n"
        description += "Bid: \(self.bid)\n"
        description += "Score: \(self.score)\n"
        description += "Cards:\n" + cardsDescription
        return description
    }
    
    // MARK: Methods
    init() {
        self.id = ""
        self.status = .none
        self.points = 0
        self.bid = 0
        self.fixBid = 0
        self.cards = [Card]()
        self.pickedCards = [false, false, false, false, false]
        self.numberOfPickedCards = 0
        self.score = .none
        self.wins = 0
        self.rounds = 0
    }
    
    func setupUser(id: String, points: Int?) {
        self.id = id
        self.points = points ?? 100
    }
    
    /// Change the player's status, bid and reduce his points
    /// - Parameter amount: the player bid
    func bet(amount: Int) {
        self.status = .didBet
        self.bid = amount
        self.points -= amount
    }
    
    /// Change the player's status, increase his bid and reduce his points
    /// - Parameter amount: the amount to increase/decrease
    func check(amount: Int) {
        self.status = .didCheck
        self.fixBid = amount
        self.points -= amount
    }
    
    /// Change the player's status, change his bid with his points and set to 0 his points
    func allIn() {
        self.status = .didCheck
        self.fixBid = self.points
        self.points = 0
    }
    
    /// Change the player's status
    func fold() {
        self.status = .fold
    }
    
    /// Change the players' cards and initialize the properties related with the cards
    /// - Parameter cards: the cards
    func receiveCards(_ cards: [Card]) {
        self.bid = 0
        self.cards = cards
        self.pickedCards = [false, false, false, false, false]
        self.numberOfPickedCards = 0
        self.tieBreakerCard = nil
        self.score = .none
    }
    
    /// Change the player's status, and player.cards property with the argument.
    /// - Parameter cards: the cards.
    /// - Parameter pickedCards: the cards picked by the player
    /// - Parameter numberOfPickedCards: the number of picked cards
    /// - Parameter tieBreakerCard: the card used if there's a tie
    /// - Parameter score: the score
    func chooseCards(cards: [Card], pickedCards: [Bool], numberOfPickedCards: Int, tieBreakerCard: Card?, score: Score) {
        self.status = .didCards
        self.cards = cards
        self.pickedCards = pickedCards
        self.numberOfPickedCards = numberOfPickedCards
        self.tieBreakerCard = tieBreakerCard
        self.score = score
    }
    
    /// Click a card states by the index passed by parameter; it can be a selection or a deselection of the card.
    /// It also compute the player's score.
    /// - Parameter index: the index of the card in the array.
    func clickCard(atIndex index: Int) {
        // Change pickedCards and numberOfPickedCards
        if self.pickedCards[index] == false {
            self.pickedCards[index] = true
            self.numberOfPickedCards = self.numberOfPickedCards + 1
        } else {
            self.pickedCards[index] = false
            self.numberOfPickedCards = self.numberOfPickedCards - 1
        }
        
        // Compute the score and the tie breaker card
        if self.numberOfPickedCards == 1 {
            let index = self.pickedCards.firstIndex(of: true)!
            self.score = Score(rawValue: self.cards[index].rank.value)!
            self.tieBreakerCard = self.cards[index]
        } else if self.numberOfPickedCards == 3 {
            // Compute the sum of the cards
            var totalThree = 0
            var totalTwo = 0
            for index in 0...4 {
                if self.pickedCards[index] == true {
                    totalThree = totalThree + self.cards[index].rank.value
                } else {
                    totalTwo = totalTwo + self.cards[index].rank.value
                    // Tie-breaker card
                    if self.tieBreakerCard == nil {
                        self.tieBreakerCard = self.cards[index]
                    } else {
                        if self.tieBreakerCard! < self.cards[index] {
                            self.tieBreakerCard = self.cards[index]
                        }
                    }
                }
            }
            // Check if the picked cards are correct
            if totalThree % 10 == 0 {
                // Score
                if totalTwo % 10 == 0 {
                    self.score = .niuNiu
                } else {
                    self.score =  Score(rawValue: ((totalTwo % 10) + 20))!
                }
            } else {
                // Error: picked cards not allowed
                self.score = .none
                self.tieBreakerCard = nil
            }
        } else {
            // Error: picked an illegal number of cards
            self.score = .none
            self.tieBreakerCard = nil
        }
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        if lhs.points == rhs.points {
            return lhs.wins < rhs.wins
        } else {
            return lhs.points < rhs.points
        }
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

}
