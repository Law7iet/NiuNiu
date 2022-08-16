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
    /// The class that communicates with clients
    var server: Server
    /// The cards
    var deck: Deck
    /// The players in the lobby
    var players: [Player]
    /// The dictionary that matches the player's name with their MCPeerID
    var playerDict = [String: MCPeerID]()
    
    var isPassedByStopCards: Bool
    var totalBid: Int
    var maxBid: Int
    
    // Game Settings
    var time: Int
    var points: Int
    
    // Others
    var timerCounter: Int
    var timer: Timer?
    
    // MARK: Methods
    init(server: Server, time: Int?, points: Int?) {
        // Game data
        self.isPassedByStopCards = false
        self.maxBid = 0
        self.totalBid = 0
        
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
        self.timerCounter = 0
        self.server.gameDelegate = self
    }
    
    // MARK: Supporting functions
    /// Get an array of MCPeerID of the players in the class with .fold or .disconnected status.
    /// The MCPeerID is taken from the playerDict, using the players' id.
    /// This is the list of the players that the Server has to send a message.
    /// - Returns: The array of MCPeerID
    func getAvailableMCPeerIDs() -> [MCPeerID] {
        var peerList = [MCPeerID]()
        for player in self.players {
            if player.status != .fold && player.status != .disconnected {
                peerList.append(self.playerDict[player.id]!)
            }
        }
        return peerList
    }
    
    /// Remove the players with status .disconnected or with points equals to 0.
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
    func startMatch(forced: Bool) {
        self.removePlayers()
        // Initialization of data
        self.maxBid = 0
        self.totalBid = 0
        // Compute players and their cards
        self.deck = Deck()
        self.deck.shuffle()
        for player in self.players {
            let cards = self.deck.getCards()
            player.receiveCards(cards)
            // Set the players' next status
            player.status = .bet
        }
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startMatch, amount: Settings.timerLong, players: self.players)
        )
    }
    
    func startBet() {
        print("Function startBet")
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startBet)
        )
    }
    
    func stopBet(forced flag: Bool) {
        print("Function stopBet")
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopBet)
        )
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
                // Change to fold only if the players is not disconnected
                player.status = .fold
            }
        }
        // Compute the leader or leaders
        var notAllChecked = false
        for player in players {
            if player.bid == self.maxBid {
                player.status = .didCheck
            } else {
                notAllChecked = true
            }
        }
        if notAllChecked == false {
            self.timerCounter = Settings.timeStartCards - 1
        }
    }
    
    func startCheck() {
        print("Function stopCheck")
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startCheck, amount: self.maxBid)
        )
    }
    
    func stopCheck(forced flag: Bool) {
        print("Function stopCheck")
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopCheck)
        )
        // Compute the total bid
        // Change the status to the players who didn't check
        self.totalBid = 0
        for player in self.players {
            if player.status == .didCheck {
                self.totalBid += player.bid
                // Set the player's next status
                player.status = .cards
            } else if player.status != .disconnected && !flag {
                // Change to fold only if the players is not disconnected
                player.status = .fold
            }
        }
    }
    
    func startCards() {
        print("Function startCards")
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startCards)
        )
    }
    
    func stopCards(forced flag: Bool) {
        print("Function stopCards")
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopCards)
        )
        // Change status to the players whose didn't choose their cards
        for player in self.players {
            if player.score == .none && player.status != .disconnected && !flag {
                // Change to fold only if the players is not disconnected
                player.status = .fold
            }
        }
        // Flag used to compute the winner
        self.isPassedByStopCards = true
    }
    
    func endMatch() {
        print("Function endMatch")
        // Compute the winner
        var winner: Player? = nil
        if self.isPassedByStopCards == true {
            for player in self.players {
                if winner == nil {
                    if player.status != .fold && player.status != .disconnected {
                        winner = player
                    }
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
        } else {
            // Should be only one player that status is not fold or disconnected
            for player in self.players {
                if player.status != .disconnected && player.status != .fold {
                    print("Winner: \(player.id) con \(player.points)")
                    winner = player
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
        self.server.sendMessage(
            to: self.server.connectedPeers,
            message: Message(.endMatch, amount: self.totalBid, players: self.players)
        )
    }
    
    func play() {
        self.startMatch(forced: false)
        self.timerCounter = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.timerCounter += 1
            switch self.timerCounter {
            case Settings.timeStartBet:
                print("StartBet")
                self.startBet()
            case Settings.timeStopBet:
                print("StopBet")
                self.stopBet(forced: false)
            case Settings.timeStartCheck:
                print("StartCheck")
                self.startCheck()
            case Settings.timeStopCheck:
                print("StopCheck")
                self.stopCheck(forced: false)
            case Settings.timeStartCards:
                print("StartCards")
                self.startCards()
            case Settings.timeStopCards:
                print("StopCards")
                self.stopCards(forced: false)
            case Settings.timeStartEnd:
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
    
    func didDisconnect(with peerID: MCPeerID) {
        // Remove from players and the dictionary the disconnected player
        if let player = Utils.findPlayer(byName: peerID.displayName, from: self.players) {
            player.status = .disconnected
        }
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        if let player = Utils.findPlayer(byName: peerID.displayName, from: self.players) {
            let message = Message(data: messageData)
            if message.type != .fold && message.players?[0] == nil {
                print("Dealer.didReceiverMessage - Missing players in message")
            } else {
                let user = message.players![0]
                switch message.type {
                // MARK: Fold
                case .fold:
                    player.fold()
                // MARK: Bet
                case .bet:
                    player.bet(amount: user.bid)
                // MARK: Check
                case .check:
                    if user.bid + player.bid == maxBid {
                        player.check(amount: user.bid)
                    } else {
                        player.allIn()
                    }
                // MARK: Cards
                case .cards:
                    player.chooseCards(
                        cards: user.cards,
                        pickedCards: user.pickedCards,
                        numberOfPickedCards: user.numberOfPickedCards,
                        tieBreakerCard: user.tieBreakerCard,
                        score: user.score
                    )
                // MARK: Request Player Data
                case .reqPlayer:
                    let player = Utils.findPlayer(byName: user.id,from: self.players)
                    if player != nil {
                        self.server.sendMessage(to: [peerID], message: Message(.resPlayer, players: [player!]))
                    }
                default:
                    print("Dealer.didReceiveMessage - Unexpected message type: \(message.type)")
                }
                
                // MARK: Check if should skip the game status
                // Compute the next game status and the current game status
                var nextStep: Int
                var currentStatus: PlayerEnum
                var callback: ((Bool) -> Void)?
                if self.timerCounter < Settings.timeStopBet {
                    nextStep = Settings.timeStopBet - 1
                    currentStatus = .didBet
                    callback = self.stopBet
                } else if self.timerCounter < Settings.timeStopCheck {
                    nextStep = Settings.timeStopCheck - 1
                    currentStatus = .didCheck
                    callback = self.stopCheck
                } else if self.timerCounter < Settings.timeStopCards {
                    nextStep = Settings.timeStopCards - 1
                    currentStatus = .didCards
                    callback = self.stopCards
                } else {
                    nextStep = Settings.timeStartEnd - 1
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
                    self.timerCounter = Settings.timeStartEnd - 1
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
