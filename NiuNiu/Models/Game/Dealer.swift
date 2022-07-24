//
//  Dealer.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

import MultipeerConnectivity

protocol DealerDelegate {
    func didStartMatch(users: [User])
    func didStartBet()
    func didStopBet()
    func didStartCheck(maxBid: Int)
    func didStopCheck()
    func didStartCards()
    func didStopCards()
    func didEndMatch(amount: Int, users: [User])
}

class Dealer {
    
    // MARK: Properties
    // Data structures
    /// The class that communicates with clients.
    var comms: Server
    /// The cards.
    var deck: Deck
    /// The host player.
    var himself: Player
    /// The players in the lobby, excluded the host player.
    var players: Players
    
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
    init(comms: Server, time: Int?, points: Int?) {
        // Game Settings
        self.time = time ?? Utils.timerLong
        self.points = points ?? Utils.points
        
        // Data Structures
        self.comms = comms
        self.deck = Deck()
        self.himself = Player(id: comms.himselfPeerID, points: points)
        self.players = Players(players: comms.connectedPeerIDs, points: points)
        
        // Others
        self.maxBid = 0
        self.totalBid = 0
        self.timerCounter = 0
        
        self.comms.serverDelegate = self
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
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.stopBet)
        )
        self.delegate?.didStopBet()
        
        // Compute the highest bid and the total bid
        // Change status to the players whose didn't bet
        for player in self.players.elements + [self.himself] {
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
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.stopCheck)
        )
        self.delegate?.didStopCheck()
        
        // Change status to the players whose didn't check
        for player in self.players.elements + [self.himself] {
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
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.stopCards)
        )
        self.delegate?.didStopCards()
        
        // Change status to the players whose didn't choose their cards
        for player in self.players.elements + [self.himself] {
            if player.score == .none {
                player.status = .fold
            }
        }
    }
    
    func endMatch() {
        // Compute the winner
        var winner: Player? = nil
        for player in self.players.elements + [self.himself] {
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
        for player in self.players.elements + [self.himself] {
            users.append(player.convertToUser())
        }
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.endMatch, amount: self.totalBid, users: users)
        )
        self.delegate?.didEndMatch(amount: self.totalBid, users: users)
    }
    
    func play() {
        var timerCounter: Int
        // Set Players and their cards
        self.makeDeck()
        var users = [User]()
        for player in self.players.elements + [self.himself] {
            let cards = self.deck.getCards()
            player.setCards(cards: cards)
            player.status = .bet
            users.append(player.convertToUser())
        }
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startMatch, users: users)
        )
        self.delegate?.didStartMatch(users: users)
        
        // Bet
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startBet)
        )
        self.delegate?.didStartBet()
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
                self.comms.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.startCheck, amount: self.maxBid)
                )
                if self.himself.status != .fold {
                    self.delegate?.didStartCheck(maxBid: self.maxBid)
                }
                // Check timer starts
                timerCounter = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if timerCounter == self.time {
                        // Check Timer ends
                        timer.invalidate()
                        self.stopCheck()
                        
                        // Cards
                        self.comms.sendMessage(
                            to: self.players.getAvailableMCPeerIDs(),
                            message: Message(.startCards)
                        )
                        self.delegate?.didStartCards()
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
extension Dealer: ServerDelegate {
    
    func didDisconnect(with: MCPeerID) {
        // TODO: Remove from players the disconnected player
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        if let player = findPlayer(byMCPeerID: peerID, from: [self.himself] + self.players.elements) {
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
