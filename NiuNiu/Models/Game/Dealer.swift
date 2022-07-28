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
    
    // MARK: Game
    func play() {
        // MARK: Initialization
        // Compute players and their cards
        self.deck = Deck()
        self.deck.shuffle()
        var users = [User]()
        for player in self.players.elements {
            let cards = self.deck.getCards()
            player.setCards(cards: cards)
            player.status = .bet
            users.append(player.convertToUser())
        }
        // Send players and their cards to clients
        self.server.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startMatch, users: users)
        )
        
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            timerCounter += 1
            switch timerCounter {
            case Utils.timerShort + Utils.timerOffset:
                // MARK: Bet - Start
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.startBet)
                )
                
            case Utils.timerShort + 2 * Utils.timerOffset + 1 * Utils.timerLong:
                // MARK: Bet - Stop
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.stopBet)
                )
                // Compute the highest bid and the total bid
                // Change the status to the players who didn't bet
                for player in self.players.elements {
                    if player.bid == 0 || player.status != .bet {
                        player.status = .fold
                    } else {
                        player.status = .check
                        if player.bid > self.maxBid {
                            self.maxBid = player.bid
                        }
                        self.totalBid += player.bid
                    }
                }
                // MARK: Check - Start
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.startCheck, amount: self.maxBid)
                )

            case Utils.timerShort + 3 * Utils.timerOffset + 2 * Utils.timerLong:
                // MARK: Check - Stop
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.stopCheck)
                )
                // Compute the total bid
                // Change the status to the players who didn't check
                self.totalBid = 0
                for player in self.players.elements {
                    if player.status == .check || player.status == .allIn {
                        player.status = .cards
                        self.totalBid += player.bid
                    } else {
                        player.status = .fold
                    }
                }
                
                // MARK: Cards - Start
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.startCards)
                )
                
            case Utils.timerShort + 3 * Utils.timerOffset + 3 * Utils.timerLong:
                // MARK: Cards - Stop
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
                // MARK: End Match
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
                winner!.status = .winner
                winner!.points = self.points + self.totalBid

                var users = [User]()
                for player in self.players.elements {
                    users.append(player.convertToUser())
                }
                self.server.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.endMatch, amount: self.totalBid, users: users)
                )
                
            default:
                break
            }
        }
    }

}

// MARK: HostManagerDelegate implementation
extension Dealer: ServerGameDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        // TODO: Remove from players the disconnected player
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        let player = self.findPlayer(byMCPeerID: peerID, from: self.players.elements)!
    
        switch message.type {
        // MARK: Bet
        case .bet:
            player.bet(amount: message.users![0].bid)
        // MARK: Check
        case .check:
            switch message.users![0].status {
            case .check: player.check(amount: message.users![0].bid)
            case .allIn: player.allIn()
            default: break
            }
        // MARK: Cards
        case .cards:
            player.pickCards(cards: message.users![0].cards!)
            
        case .reqPlayer:
            let player = Utils.findPlayer(byName: message.users![0].name,from: self.players.elements)
            if player != nil {
                self.server.sendMessage(to: [peerID], message: Message(.resPlayer, users: [player!.convertToUser()]))
            }
            
        default:
            print("Delaer.didReceiveMessage - Unexpected message type: \(message.type)")
        }
    }
    
}
