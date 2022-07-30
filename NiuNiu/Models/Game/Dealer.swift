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
    var players: [Player]
    
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
        self.players = [Player]()
        for peerID in server.clientsPeerIDs {
            players.append(Player(id: peerID, points: points))
        }
        
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
    
    /// Get an array of MCPeerID of the players in the class with .fold status.
    /// This is the list of the players that the Server has to send a message.
    /// - Returns: The array of MCPeerID
    func getAvailableMCPeerIDs() -> [MCPeerID] {
        var peerList = [MCPeerID]()
        for player in self.players {
            if player.status != .fold {
                peerList.append(player.id)
            }
        }
        return peerList
    }
    
    // MARK: Game
    func startMatch() {
        // Compute players and their cards
        self.deck = Deck()
        self.deck.shuffle()
        var users = [User]()
        for player in self.players {
            let cards = self.deck.getCards()
            player.cards = cards
            player.status = .bet
            users.append(player.convertToUser())
        }
        // Send players and their cards to clients
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startMatch, users: users)
        )
    }
    
    func startBet() {
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startBet)
        )
    }
    
    func stopBet() {
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopBet)
        )
        // Compute the highest bid and the total bid
        // Change the status to the players who didn't bet
        for player in self.players {
            if player.bid <= 0 || player.status != .bet {
                player.status = .fold
            } else {
                player.status = .check
                if player.bid > self.maxBid {
                    self.maxBid = player.bid
                }
                self.totalBid += player.bid
            }
        }
    }
    
    func startCheck() {
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startCheck, amount: self.maxBid)
        )
    }
    
    func stopCheck() {
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopCheck)
        )
        // Compute the total bid
        // Change the status to the players who didn't check
        self.totalBid = 0
        for player in self.players {
            if player.status == .check || player.status == .allIn {
                player.status = .cards
                self.totalBid += player.bid
            } else {
                player.status = .fold
            }
        }
    }
    
    func startCards() {
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startCards)
        )
    }
    
    func stopCards() {
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopCards)
        )
        // Change status to the players whose didn't choose their cards
        for player in self.players {
            if player.score == .none {
                player.status = .fold
            }
        }
    }
    
    func endMatch() {
        // Compute the winner
        var winner: Player? = nil
        for player in self.players {
            if winner == nil {
                winner = player
            } else {
                if player.score != .none {
                    if player.score > winner!.score {
                        winner = player
                    } else if player.score == winner!.score {
                        if player.tieBreakerCard! > winner!.tieBreakerCard! {
                            winner = player
                        }
                    }
                }
            }
        }
        winner!.status = .winner
        winner!.points = winner!.points + self.totalBid
        
        var users = [User]()
        for player in self.players {
            users.append(player.convertToUser())
        }
        self.server.sendMessage(
            to: self.server.clientsPeerIDs,
            message: Message(.endMatch, amount: self.totalBid, users: users)
        )
    }
    
    func play() {
        self.startMatch()
        
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            timerCounter += 1
            switch timerCounter {
            case Utils.timerShort + Utils.timerOffset:
                self.startBet()
            case Utils.timerShort + 2 * Utils.timerOffset + 1 * Utils.timerLong:
                self.stopBet()
                self.startCheck()
            case Utils.timerShort + 3 * Utils.timerOffset + 2 * Utils.timerLong:
                self.stopCheck()
                self.startCards()
            case Utils.timerShort + 3 * Utils.timerOffset + 3 * Utils.timerLong:
                self.stopCards()
                self.endMatch()
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
        let player = self.findPlayer(byMCPeerID: peerID, from: self.players)!
    
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
            player.chooseCards(
                cards: message.users![0].cards,
                pickedCards: message.users![0].pickedCards,
                numberOfPickedCards: message.users![0].numberOfPickedCards,
                tieBreakerCard: message.users![0].tieBreakerCard,
                score: message.users![0].score
            )
        case .reqPlayer:
            let player = Utils.findPlayer(byName: message.users![0].name,from: self.players)
            if player != nil {
                self.server.sendMessage(to: [peerID], message: Message(.resPlayer, users: [player!.convertToUser()]))
            }
            
        default:
            print("Delaer.didReceiveMessage - Unexpected message type: \(message.type)")
        }
    }
    
}
