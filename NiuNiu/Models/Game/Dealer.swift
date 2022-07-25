//
//  Dealer.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

import MultipeerConnectivity

class Dealer {
    
    // MARK: Properties
    // Data structures
    /// The class that communicates with clients.
    var server: Server
    /// The cards.
    var deck: Deck
    /// The players in the lobby
    var players: Players
    
    // Game Settings
    var time: Int
    var points: Int
    
    // Others
    var timerCounter: Int
    var totalBid: Int
    var maxBid: Int
    var winner: Player?
    
    // MARK: Methods
    init(server: Server, time: Int?, points: Int?) {
        // Game Settings
        self.time = time ?? Utils.timerLong
        self.points = points ?? Utils.points
        
        // Data Structures
        self.server = server
        self.deck = Deck()
        self.players = Players(players: server.clientsPeerIDs, points: points)
        
        // Others
        self.maxBid = 0
        self.totalBid = 0
        self.timerCounter = 0
        
        self.server.gameDelegate = self
    }
    
    // MARK: Supporting functions
    func findPlayer(byMCPeerID peerID: MCPeerID, from players: [Player]) -> Player? {
        for player in players {
            if player.id == peerID {
                return player
            }
        }
        return nil
    }
    
    // MARK: Game's methods
    func makeDeck() {
        self.deck = Deck()
        self.deck.shuffle()
    }
    
    func stopBet() {
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.stopBet)
        )
        
        // Compute the highest bid and the total bid
        // Change status to the players whose didn't bet
        for player in self.players.elements {
            if player.bid == 0 {
                player.status = .fold
            } else {
                if player.bid > self.maxBid {
                    self.maxBid = player.bid
                }
                self.totalBid += player.bid
            }
        }
        print("totalBid: \(self.totalBid)")
    }
    
    func stopCheck() {
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.stopCheck)
        )
        
        // Change status to the players whose didn't check
        for player in self.players.elements {
            if player.bid != self.maxBid {
                if player.bid == 0 {
                    if player.status != .allIn{
                        player.status = .fold
                    }
                } else {
                    self.totalBid += player.bid
                }
            }
        }
        
        print("totalBid: \(self.totalBid)")
    }
    
    func stopCards() {
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.stopCards)
        )
        
        // Change status to the players whose didn't choose their cards
        for player in self.players.elements {
            if player.score == .none {
                player.status = .fold
            }
        }
    }
    
    func endMatch() {
        // Compute the winner
        var winner: Player? = nil
        for player in self.players.elements {
            if winner == nil {
                winner = player
            } else {
                if player.score != .none {
                    if player.score > winner!.score {
                        winner = player
                    } else if player.score == winner!.score {
                        if player.cards!.tieBreakerCard! > winner!.cards!.tieBreakerCard! {
                            winner = player
                        }
                    }
                }
            }
        }
        winner!.isWinner = true
        winner!.points = points + self.totalBid

        var users = [User]()
        for player in self.players.elements {
            users.append(player.convertToUser())
        }
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.endMatch, amount: self.totalBid, users: users)
        )
    }
    
    func play() {
        var timerCounter: Int
        // Set Players and their cards
        self.makeDeck()
        var users = [User]()
        for player in self.players.elements {
            let cards = self.deck.getCards()
            player.setCards(cards: cards)
            player.status = .bet
            users.append(player.convertToUser())
        }
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startMatch, users: users)
        )
        
        // Bet
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startBet)
        )

        // Bet timer starts
        timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timerCounter == self.time {
                // Bet timer ends
                timer.invalidate()
                self.stopBet()
                
//                // Change players' status to .check
//                for player in self.players.elements + [self.himself] {
//                    if player.status != .fold {
//                        player.status = .check
//                    }
//                }
                // Check
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.startCheck, amount: self.maxBid)
                )
                
                // Check timer starts
                timerCounter = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if timerCounter == self.time {
                        // Check Timer ends
                        timer.invalidate()
                        self.stopCheck()
                        
                        // Cards
                        self.server.sendMessage(
                            to: self.players.getAvailableMCPeerIDs(),
                            message: Message(.startCards)
                        )
                
                        // Cards timer starts
                        timerCounter = 0
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                            if timerCounter == self.time {
                                // Cards timer ends
                                timer.invalidate()
                                self.stopCards()
                                
                                // End Match
                                self.endMatch()
                            }
                            timerCounter = timerCounter + 1
                        }
                    }
                    timerCounter = timerCounter + 1
                }
            }
            timerCounter = timerCounter + 1
        }
    }
        
}

// MARK: HostManagerDelegate implementation
extension Dealer: ServerGameDelegate {
    
    func didDisconnect(with: MCPeerID) {
        // TODO: Remove from players the disconnected player
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        if let player = findPlayer(byMCPeerID: peerID, from: self.players.elements) {
            switch message.type {
            case .bet:
                player.bid = message.users![0].bid
                player.points = message.users![0].points
            case .check:
                player.bid = player.bid + message.users![0].bid
                player.points = message.users![0].points
            case .cards:
                let cards = message.users![0].cards!
                player.cards = cards
            default:
                print("Delaer.didReceiveMessage - Unexpected message type: \(message.type)")
            }
        } else {
            print("\(peerID) not found in the players")
            return
        }
    }
    
}
