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
    /// The players in the lobby.
    var players: [Player]
    /// The dictionary that matches the player's name with their `MCPeerID`.
    var playerDict = [String: MCPeerID]()
    
    // Game Settings
    var time: Int
    var points: Int
    
    // Others
    var maxBid: Int
    var totalBid: Int
    var timerCounter: Int
    var timer: Timer?
    
    // MARK: Methods
    init(server: Server, time: Int?, points: Int?) {
        print("Dealer init")
        // Game Settings
        self.time = time ?? Settings.timerLong
        self.points = points ?? Settings.points
        // Data Structures
        self.server = server
        self.deck = Deck()
        self.players = [Player]()
        for peerID in server.connectedPeers {
            players.append(Player(id: peerID.displayName, points: points))
            self.playerDict[peerID.displayName] = peerID
        }
        // Others
        self.maxBid = 0
        self.totalBid = 0
        self.timerCounter = 0
        self.server.gameDelegate = self
    }
    
    // MARK: Supporting functions
    /// Remove the players with status `.disconnected` or with points equals to 0.
    /// This is must called before and match.
    func removePlayers() {
        for player in self.players {
            if player.status == .disconnected || player.points == 0 {
                let index = self.players.firstIndex(of: player)!
                self.players.remove(at: index)
                self.playerDict.removeValue(forKey: player.id)
            }
        }
    }
    
    // MARK: Game functions
    /// Setups the data and send a message to notify the clients.
    /// The data to setup are: the clients to remove from the previous round, the internal data and the players
    func startMatch() {
        print("startMatch()")
        // Remove disconnected players
        self.removePlayers()
        // Initialization of data
        self.maxBid = 0
        self.totalBid = 0
        self.deck = Deck()
        for player in self.players {
            // Set the players' cards and next status
            let cards = self.deck.getFiveCards()
            player.receiveCards(cards)
            player.status = .bet
        }
        // Send message
        self.server.sendMessage(Message(
            .startMatch,
            amount: Settings.timerLong,
            players: self.players
        ))
    }
    
    /// Send a message to notify the active players of the begining of the bet.
    func startBet() {
        print("startBet()")
        // Send message
        self.server.sendMessage(Message(.startBet))
    }
    
    /// Send a message to notify the active players of the ending of the bet.
    /// It computes the highest bid, the total bid and the leaders.
    /// The leaders are the players whose bid is equal to the highest bid.
    /// If it'snt forced, it convert the player who didn't bet to `.fold` status.
    /// - Parameter flag: it states if the function is not called by the `play()` function.
    func stopBet(forced flag: Bool) {
        print("stopBet(forced: \(flag))")
        // Send message
        self.server.sendMessage(Message(.stopBet, amount: flag ? 1 : 0))
        // Compute the highest bid
        // Change the status to the players who didn't bet
        for player in self.players {
            if player.bid > 0 && player.status == .didBet {
                // Set the players' next status
                player.status = .check
                // Increase total bid and compute the highest bid
                self.totalBid += player.bid
                if player.bid > self.maxBid {
                    self.maxBid = player.bid
                }
            } else if player.status != .disconnected && !flag {
                // Change to fold only if the players is not disconnected and the timer properly ended
                player.status = .fold
            }
        }
        if !flag {
            // Compute and change the leader or leaders' status
            var notAllLeaders = false
            for player in players {
                if player.bid == self.maxBid {
                    player.status = .didCheck
                } else {
                    notAllLeaders = true
                }
            }
            // If all are leader it skips to the pick cards status
            if notAllLeaders == false {
                self.timerCounter = Utils.timeStartCards - 1
            }
        }
    }
    
    /// Send a message to notify the active players of the begining of the check.
    func startCheck() {
        print("startCheck()")
        // Send message
        self.server.sendMessage(Message(.startCheck, amount: self.maxBid))
    }
    
    /// Send a message to notify the active players of the ending of the check. and computes the total bid.
    /// If it'snt forced, it convert the player who didn't check to `.fold` status.
    /// - Parameter flag: it states if the function is not called by the `play()` function.
    func stopCheck(forced flag: Bool) {
        print("stopCheck(forced: \(flag))")
        // Send message
        self.server.sendMessage(Message(.stopCheck, amount: flag ? 1 : 0))
        // Compute the total bid
        // Change the status to the players who didn't check
        if !flag {
            for player in self.players {
                if player.status == .didCheck {
                    self.totalBid += player.fixBid
                    // Set the player's next status
                    player.status = .cards
                } else if player.status != .disconnected && !flag {
                    // Change to fold only if the players is not disconnected and the timer properly ended
                    player.status = .fold
                }
            }
        }
    }
    
    /// Send a message to notify the active players of the begining of the cards.
    func startCards() {
        print("startCards()")
        // Send message
        self.server.sendMessage(Message(.startCards))
    }
    
    /// Send a message to notify the clients of the ending of the cards.
    /// If it'snt forced, it convert the player who didn't choose their cards to `.fold` status.
    /// - Parameter flag: it states if the function is not called by the `play()` function.
    func stopCards(forced flag: Bool) {
        print("stopCards(forced: \(flag))")
        // Send message
        self.server.sendMessage(Message(.stopCards, amount: flag ? 1 : 0))
        // Change status to the players whose didn't choose their cards
        for player in self.players {
            if player.score == .none && player.status != .disconnected && !flag {
                // Change to fold only if the players is not disconnected and the timer properly ended
                player.status = .fold
            }
        }
//        // Flag used to compute the winner
//        self.isForced = flag
    }
    
    /// Compute the winner, sort the players for the scoreboard and send a message to the all the players the end of the round.
    func endMatch() {
        print("endMatch()")
        // Compute the winner
        var winner: Player? = nil
        for player in self.players {
            if player.status != .fold && player.status != .disconnected {
                if winner == nil {
                    winner = player
                } else {
                    if player.score > winner!.score {
                        winner = player
                    } else if player.score == winner!.score {
                        // Tie breaker
                        if player.tieBreakerCard! > winner!.tieBreakerCard! {
                            winner = player
                        }
                    }
                }
            }
        }
        if winner != nil {
            winner!.status = .winner
            winner!.points = winner!.points + self.totalBid
        }
        // Sort the players for the scoreboard
        self.players.sort()
        self.players.reverse()
        // Send message
        self.server.sendMessage(Message(
            .endMatch,
            amount: self.totalBid,
            players: self.players
        ))
    }
    
    /// Start a round.
    func play() {
        self.startMatch()
        self.timerCounter = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.timerCounter += 1
            switch self.timerCounter {
            case Utils.timeStartBet:
                print("StartBet")
                self.startBet()
            case Utils.timeStopBet:
                print("StopBet")
                self.stopBet(forced: false)
            case Utils.timeStartCheck:
                print("StartCheck")
                self.startCheck()
            case Utils.timeStopCheck:
                print("StopCheck")
                self.stopCheck(forced: false)
            case Utils.timeStartCards:
                print("StartCards")
                self.startCards()
            case Utils.timeStopCards:
                print("StopCards")
                self.stopCards(forced: false)
            case Utils.timeStartEnd:
                print("StartEnd")
                self.endMatch()
            default:
                break
            }
        }
    }

}

// MARK: HostManagerDelegate implementation
extension Dealer: ServerGameDelegate {
    
    /// It is called when a peer is disconnected.
    /// - Parameter peerID: the disconnected peer
    func didDisconnect(with peerID: MCPeerID) {
        // Remove from players and the dictionary the disconnected player
        if let player = Utils.findPlayer(byName: peerID.displayName, from: self.players) {
            player.status = .disconnected
        }
    }
    
    /// It is called when it receives a message from the client.
    /// The message is managed by its type.
    /// - Parameters:
    ///   - peerID: the sender.
    ///   - messageData: the message.
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        // It should be called by a players in the data
        if let player = Utils.findPlayer(byName: peerID.displayName, from: self.players) {
            // It should have a non-empty message
            let message = Message(data: messageData)
            if message.type != .fold && message.players?[0] == nil {
                print("Dealer.didReceiverMessage - Missing players in message")
            } else {
                let user = message.players![0]
                switch message.type {
                // MARK: Fold
                case .fold:
                    print("\(player.id) fold")
                    player.fold()
                    self.server.sendMessage(
                        Message(.notify, players: [player])
                    )
                // MARK: Bet
                case .bet:
                    player.bet(amount: user.bid)
                    self.server.sendMessage(
                        Message(.notify, players: [player])
                    )
                // MARK: Check
                case .check:
                    if user.bid + user.fixBid == maxBid {
                        player.check(amount: user.bid)
                    } else {
                        player.allIn()
                    }
                    self.server.sendMessage(
                        Message(.notify, players: [player])
                    )
                // MARK: Cards
                case .cards:
                    player.chooseCards(
                        cards: user.cards,
                        pickedCards: user.pickedCards,
                        numberOfPickedCards: user.numberOfPickedCards,
                        tieBreakerCard: user.tieBreakerCard,
                        score: user.score
                    )
                    self.server.sendMessage(
                        Message(.notify, players: [player])
                    )
                // MARK: Request Player Data
                case .reqPlayer:
                    let player = Utils.findPlayer(byName: user.id,from: self.players)
                    if player != nil {
                        self.server.sendMessage(
                            to: [peerID],
                            message: Message(.resPlayer, players: [player!]))
                    }
                default:
                    print("Dealer.didReceiveMessage - Unexpected message type: \(message.type)")
                }
                
                // MARK: Check if should skip the game status
                // Compute the next game status and the current game status
                var nextStep: Int
                var currentStatus: PlayerStatus
                var callback: ((Bool) -> Void)?
                if self.timerCounter < Utils.timeStopBet {
                    nextStep = Utils.timeStopBet - 1
                    currentStatus = .didBet
                    callback = self.stopBet
                } else if self.timerCounter < Utils.timeStopCheck {
                    nextStep = Utils.timeStopCheck - 1
                    currentStatus = .didCheck
                    callback = self.stopCheck
                } else if self.timerCounter < Utils.timeStopCards {
                    nextStep = Utils.timeStopCards - 1
                    currentStatus = .didCards
                    callback = self.stopCards
                } else {
                    nextStep = Utils.timeStartEnd - 1
                    currentStatus = .none
                    callback = nil
                }
                // Count active players and not active players
                var foldedCounter = 0
                var playedCounter = 0
                for player in self.players {
                    if player.status == .fold || player.status == .disconnected {
                        foldedCounter += 1
                    } else if player.status == currentStatus {
                        playedCounter += 1
                    }
                }
                // Compute
                if foldedCounter >= self.players.count - 1 {
                    // Go to endMatch
                    callback?(true)
                    self.timerCounter = Utils.timeStartEnd - 1
                } else if foldedCounter + playedCounter == self.players.count {
                    // Go to next step
                    self.timerCounter = nextStep
                }
            }
        } else {
           print("Dealer.didReceiveMessage - Unexpected sender: \(peerID.displayName)")
        }
    }
    
}
