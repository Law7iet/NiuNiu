//
//  Dealer.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

import MultipeerConnectivity

protocol DealerDelegate {
    
    func didReciveCards(cards: [Card])
    
}

class Dealer {
    
    // MARK: Properties
    var serverManager: HostManager
    
    var deck: Deck
    var players: [Player]
    var maxBid: Int
    var totalBid: Int
    var timer: Int
    var timerCounter: Int
    var activePlayers: [MCPeerID]
    
    var delegate: DealerDelegate?
    
    // MARK: Methods
    init(serverManager: HostManager, players: [MCPeerID], timer: Int?) {
        self.serverManager = serverManager
        
        self.deck = Deck()
        self.players = [Player]()
        for player in players {
            self.players.append(Player(id: player, points: nil))
        }
        self.maxBid = 0
        self.totalBid = 0
        self.timer = timer ?? 30
        self.timerCounter = 0
        self.activePlayers = [MCPeerID]()
    }
    
    // MARK: Supporting functions
    func makeDeck() {
        self.deck = Deck()
        self.deck.shuffle()
    }
        
    func findPlayerWith(peerID: MCPeerID) -> Player? {
        for player in players {
            if player.id == peerID {
                return player
            }
        }
        return nil
    }
    
    func findActivePlayers() -> [Player] {
        var activePlayers = [Player]()
        for player in self.players {
            if player.isOut {
                activePlayers.append(player)
            }
        }
        return activePlayers
    }
    
    func startTimerWithEndMessage(type: MessageEnum, time: Int) {
        var timerCounter = 0
        // Start a timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.serverManager.sendMessageTo(receivers: self.activePlayers, message: Message(type: .timer, amount: time - timerCounter))
            timerCounter = timerCounter + 1
            if timerCounter == time {
                // Timer ends
                timer.invalidate()
                self.serverManager.sendMessageTo(receivers: self.activePlayers, message: Message(type: type))
            }
        }
    }
    
    // MARK: Game
    func playGame() {
        
        // Start the game
        self.serverManager.sendBroadcastMessage(Message(type: .startGame))
        // Prepare the cards and give 5 cards to each player
        self.makeDeck()
        for player in self.players {
            let cards = self.deck.getCards()
            player.cards = cards
            if player.id == self.serverManager.myPeerID {
                // Change UI of the server
                self.delegate?.didReciveCards(cards: player.cards)
            } else {
                // Send a message with cards to the guests
                self.serverManager.sendMessageTo(receivers: [player.id], message: Message(type: .receiveCards, cards: cards))
            }
        }
        self.activePlayers = Utils.convertPlayersToMCPeerIDList(players: self.findActivePlayers())
        
        // Bet
        self.serverManager.sendBroadcastMessage(Message(type: .startBet))
        self.startTimerWithEndMessage(type: .endBet, time: self.timer)
        
        // Change status to the players whose didn't bet
        for player in self.players {
            if player.bid == 0 {
                player.isOut = false
            }
        }
        self.activePlayers = Utils.convertPlayersToMCPeerIDList(players: self.findActivePlayers())
        
        // Fix bet
        self.serverManager.sendMessageTo(receivers: activePlayers, message: Message(type: .startFixBet))
        self.startTimerWithEndMessage(type: .endFixBet, time: self.timer)
        
        // Change status to the players whose didn't fixbet
        for player in self.players {
            if player.bid == self.maxBid {
                player.isOut = false
            }
        }
        self.activePlayers = Utils.convertPlayersToMCPeerIDList(players: self.findActivePlayers())
        
        // Start pick cards
        self.serverManager.sendMessageTo(receivers: activePlayers, message: Message(type: .startPickCards))
        self.startTimerWithEndMessage(type: .endPickCards, time: self.timer)
                
        // Change status to the players whose didn't pickCards
        for player in self.players {
            if player.pickedCards.isEmpty {
                player.isOut = false
            }
        }
        self.activePlayers = Utils.convertPlayersToMCPeerIDList(players: self.findActivePlayers())
        
        // Compute the winner
//        for player in self.activePlayers {
//            // TODO: Compute the winner
//        }
        // Show cards
        self.serverManager.sendMessageTo(receivers: self.activePlayers, message: Message(type: .showCards))
        
        // TODO: notify the winner
        // TODO: Give to the winner the prize
        
        // End Game
        self.serverManager.sendBroadcastMessage(Message(type: .endMatch))

    }
        
}

// MARK: HostManagerDelegate implementation
extension Dealer: HostManagerDelegate {
    
    func didConnectWith(peerID: MCPeerID) {}
    func didDisconnectWith(peerID: MCPeerID) {}
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .bet:
            // Add the bid of the player with peerID
            print("bet")
            if let bid = message.amount {
                let player = self.findPlayerWith(peerID: peerID)
                if player?.bet(amount: bid) == true {
                    self.totalBid = self.totalBid + message.amount!
                    if bid > self.maxBid {
                        self.maxBid = bid
                    }
                } else {
                    print("Error server shouldn't receive this message: player has not enough points for his bid")
                }
            } else {
                print("Message .bet has nil amount")
            }
        case .fixBet:
            // Change the bid of the player with peerID
            print("fixBet")
            if let bid = message.amount {
                let player = self.findPlayerWith(peerID: peerID)
                if player?.bet(amount: bid) == true {
                    self.totalBid = self.totalBid + message.amount!
                } else {
                    print("Error server shouldn't receive this message: player has not enough points for his bid")
                }
            } else {
                print("Message .fixBet has nil amount")
            }
        case .pickCards:
            // Change the picked cards of the player with peerID
            print("pickCards")
            if let cards = message.cards {
                let player = self.findPlayerWith(peerID: peerID)
                player?.pickedCards = cards
            } else {
                print("Message .pickCards has nil cards")
            }
            
        default:
            print("MessageType \(message.type) not allowed")
        }
    }
    
}
