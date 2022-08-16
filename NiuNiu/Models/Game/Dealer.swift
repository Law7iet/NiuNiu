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
    
    // Game data
    var leader: Player?
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
        self.leader = nil
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
    
    /// Check if the players status are equals to the status passed by input.
    /// If a player's status is disconnected or fold, it continue the control.
    /// If the check status is check, it includes the allIn status.
    /// - Parameter status: the status
    /// - Returns: a boolean value
    func checkPlayersStatus(status: PlayerEnum) -> Bool {
        for player in self.players {
            if player.status == .disconnected || player.status == .fold {
                continue
            } else {
                if player.status == status || status == .didCheck && player.status == .didAllIn {
                    continue
                }
            }
            return false
        }
        return true
    }
    
    // MARK: Game functions
    func startMatch() {
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
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startBet)
        )
    }
    
    func stopBet() {
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopBet)
        )
        // Compute the highest bid
        // Change the status to the players who didn't bet
        for player in self.players {
            if player.bid > 0 && player.status == .didBet {
                if player.bid > self.maxBid {
                    self.maxBid = player.bid
                    self.leader = player
                }
                // Set the players' next status
                player.status = .check
            } else if player.status != .disconnected {
                // Change to fold only if the players is not disconnected
                player.status = .fold
            }
        }
        self.leader!.status = .didCheck
    }
    
    func startCheck() {
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startCheck, amount: self.maxBid)
        )
    }
    
    func stopCheck() {
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopCheck)
        )
        // Compute the total bid
        // Change the status to the players who didn't check
        for player in self.players {
            if (player.status == .didCheck && player.bid == self.maxBid) || (player.status == .didAllIn) {
                self.totalBid += player.bid
                // Set the player's next status
                player.status = .cards
            } else if player.status != .disconnected {
                // Change to fold only if the players is not disconnected
                player.status = .fold
            }
        }
    }
    
    func startCards() {
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.startCards)
        )
    }
    
    func stopCards() {
        // Send message
        self.server.sendMessage(
            to: self.getAvailableMCPeerIDs(),
            message: Message(.stopCards)
        )
        // Change status to the players whose didn't choose their cards
        for player in self.players {
            if player.score == .none && player.status != .disconnected {
                // Change to fold only if the players is not disconnected
                player.status = .fold
            }
        }
    }
    
    func endMatch() {
        // Compute the winner
        var winner: Player? = nil
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
        self.startMatch()
        self.timerCounter = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.timerCounter += 1
            print(self.timerCounter)
            switch self.timerCounter {
            case Settings.timeStartBet:
                print("StartBet")
                self.startBet()
            case Settings.timeStopBet:
                print("StopBet")
                self.stopBet()
            case Settings.timeStartCheck:
                print("StartCheck")
                self.startCheck()
            case Settings.timeStopCheck:
                print("StopCheck")
                self.stopCheck()
            case Settings.timeStartCards:
                print("StartCards")
                self.startCards()
            case Settings.timeStopCards:
                print("StopCards")
                self.stopCards()
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
                    if self.checkPlayersStatus(status: .fold) == true {
                        self.timerCounter = Settings.timeStartEnd - 1
                    }
                // MARK: Bet
                case .bet:
                    player.bet(amount: user.bid)
                    if self.checkPlayersStatus(status: .didBet) == true {
                        self.timerCounter = Settings.timeStartCheck - 1
                    }
                    
                // MARK: Check
                case .check:
                    switch user.status {
                    case .didCheck: player.check(amount: user.bid)
                    case .didAllIn: player.allIn()
                    default: break
                    }
                    if self.checkPlayersStatus(status: .didCheck) == true {
                        self.timerCounter = Settings.timeStartCards - 1
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
                    if self.checkPlayersStatus(status: .didCards) == true {
                        self.timerCounter = Settings.timeStartEnd - 1
                    }
                // MARK: Request Player Data
                case .reqPlayer:
                    let player = Utils.findPlayer(byName: user.id,from: self.players)
                    if player != nil {
                        self.server.sendMessage(to: [peerID], message: Message(.resPlayer, players: [player!]))
                    }
                default:
                    print("Dealer.didReceiveMessage - Unexpected message type: \(message.type)")
                }
            }
        } else {
           print("Dealer.didReceiveMessage - Unexpected sender: \(peerID.displayName)")
        }
    }
    
}
