//
//  Dealer.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

import MultipeerConnectivity

protocol DealerDelegate {
    
    func didStartGame(player: Player)
    func didStartMatch(players: Players)
    func didReceiveCards(cards: Cards)
    
}

class Dealer {
    
    // MARK: Properties
    // Data Strucutres
    var serverManager: HostManager
    var players: Players
    var deck: Deck
    var himself: Player
    // Game Settings
    var time: Int
    var points: Int
    // Others
    var winner: Player?
    var maxBid: Int
    var totalBid: Int
    var timerCounter: Int
    
    
    var delegate: DealerDelegate?
    
    // MARK: Methods
    init(serverManager: HostManager, players: [MCPeerID], time: Int?, points: Int?) {
        // Game Settings
        self.time = time ?? 30
        self.points = points ?? 100
        // Data Structures
        self.serverManager = serverManager
        self.deck = Deck()
        self.players = Players(players: players, points: self.points)
        self.himself = self.players.findPlayerById(self.serverManager.myPeerID)!
        // Others
        self.maxBid = 0
        self.totalBid = 0
        self.timerCounter = 0
    }
    
    // MARK: Supporting functions
    func makeDeck() {
        self.deck = Deck()
        self.deck.shuffle()
    }
    
    func startTimerWithEndMessage(type: MessageEnum, time: Int) {
        var timerCounter = 0
        // Start a timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.serverManager.sendMessageTo(
                receivers: self.players.getAvailableMCPeersID(except: self.himself.id),
                message: Message(type: .timer, amount: time - timerCounter)
            )
            timerCounter = timerCounter + 1
            if timerCounter == time {
                // Timer ends
                timer.invalidate()
                self.serverManager.sendMessageTo(
                    receivers: self.players.getAvailableMCPeersID(except: self.himself.id),
                    message: Message(type: type)
                )
            }
        }
    }
    
    // MARK: Game
    func playGame() {
        
        // Start the game
        self.serverManager.sendMessageTo(
            receivers: self.players.getAvailableMCPeersID(except: self.serverManager.myPeerID),
            message: Message(type: .startGame, amount: self.points)
        )
        if let himself = self.players.findPlayerById(self.serverManager.myPeerID) {
            self.delegate?.didStartGame(player: himself)
        } else {
            // Error
            return
        }
        // Start the match

        
        // Prepare the cards and give 5 cards to each player
        self.makeDeck()
        for player in self.players.elements {
            let cards = self.deck.getCards()
            player.setCards(cards: cards)
            // Check if the player is himself or not
            if player.id == self.serverManager.myPeerID {
                // Change UI of the server
                self.delegate?.didReceiveCards(cards: player.cards!)
            } else {
                // Send a message with cards to the guests
                self.serverManager.sendMessageTo(
                    receivers: [player.id],
                    message: Message(type: .receiveCards, cards: player.cards!))
            }
        }
        
//        // Bet
//        self.serverManager.sendMessageTo(
//            receivers: self.activePlayers.getMCPeersID(),
//            message: Message(type: .startBet)
//        )
//        self.startTimerWithEndMessage(type: .endBet, time: self.time)
//
//        // Change status to the players whose didn't bet
//        for player in self.players.list {
//            if player.bid == 0 {
//                player.status = .fold
//            }
//        }
//        self.activePlayers.findActivePlayers()
//
//        // Fix bet
//        self.serverManager.sendMessageTo(
//            receivers: self.activePlayers.getMCPeersID(),
//            message: Message(type: .startFixBid)
//        )
//        self.startTimerWithEndMessage(type: .endFixBid, time: self.time)
//
//        // Change status to the players whose didn't fixbet
//        for player in self.players.list {
//            if player.bid == self.maxBid {
//                player.status = .fold
//            }
//        }
//        self.activePlayers.findActivePlayers()
//
//        // Start pick cards
//        self.serverManager.sendMessageTo(
//            receivers: self.activePlayers.getMCPeersID(),
//            message: Message(type: .startChooseCards)
//        )
//        self.startTimerWithEndMessage(type: .endChooseCards, time: self.time)
//
//        // Change status to the players whose didn't pickCards
//        for player in self.players.list {
//            if player.cards.numberOfPickedCards != 1 || player.cards.numberOfPickedCards != 3 {
//                player.status = .fold
//            }
//        }
//        self.activePlayers.findActivePlayers()
//
//        // Compute the winner
//        for player in self.activePlayers.list {
//            if self.winner == nil {
//                self.winner = player
//            } else {
//                if self.winner!.score < player.score {
//                    self.winner = player
//                }
//            }
//        }
//        // Show cards
//        self.serverManager.sendMessageTo(
//            receivers: self.activePlayers.getMCPeersID(),
//            message: Message(type: .showCards)
//        )
//        // Notify the winner and give him the prize
//        self.serverManager.sendMessageTo(
//            receivers: self.activePlayers.getMCPeersID(),
//            message: Message(type: .winner, amount: self.totalBid, player: self.winner!.id.displayName)
//        )
//
//        // End Game
//        self.serverManager.sendBroadcastMessage(Message(type: .endMatch))
//        self.activePlayers = self.players
    }
        
}

// MARK: HostManagerDelegate implementation
extension Dealer: HostManagerDelegate {
    
    func didConnectWith(peerID: MCPeerID) {}
    func didDisconnectWith(peerID: MCPeerID) {}
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
//        let message = Message(data: messageData)
//        switch message.type {
//        case .bet:
//            // Add the bid of the player with peerID
//            print("bet")
//            if let bid = message.amount {
//                let player = self.activePlayers.findPlayerWith(peerID: peerID)
//                if player?.bet(amount: bid) == true {
//                    self.totalBid = self.totalBid + message.amount!
//                    if bid > self.maxBid {
//                        self.maxBid = bid
//                    }
//                } else {
//                    print("Error server shouldn't receive this message: player has not enough points for his bid")
//                }
//            } else {
//                print("Message .bet has nil amount")
//            }
//        case .fixBid:
//            // Change the bid of the player with peerID
//            print("fixBet")
//            if let bid = message.amount {
//                let player = self.activePlayers.findPlayerWith(peerID: peerID)
//                if player?.bet(amount: bid) == true {
//                    self.totalBid = self.totalBid + message.amount!
//                } else {
//                    print("Error server shouldn't receive this message: player has not enough points for his bid")
//                }
//            } else {
//                print("Message .fixBet has nil amount")
//            }
//        case .chooseCards:
//            // Change the picked cards of the player with peerID
//            print("pickCards")
//            if let cards = message.cards {
//                let player = self.activePlayers.findPlayerWith(peerID: peerID)
//                player?.cards = cards
//            } else {
//                print("Message .pickCards has nil cards")
//            }
//            
//        default:
//            print("MessageType \(message.type) not allowed")
//        }
    }
    
}
