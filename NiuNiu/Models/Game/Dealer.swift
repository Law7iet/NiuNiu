//
//  Dealer.swift
//  NiuNiu
//
//  Created by Han Chu on 12/07/22.
//

import MultipeerConnectivity

protocol DealerDelegate {
    func didStartGame(player: Player)
    func didStartMatch(users: [User])
    func didReceiveCards(cards: Cards)
    func didStartBet()
    func didStopBet()
    func didStartFixBid(maxBid: Int)
    func didStopFixBid()
    
    func didReceiveTimer(timer: Int)
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
        self.time = time ?? 30
        self.points = points ?? 100
        
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
    func makeDeck() {
        self.deck = Deck()
        self.deck.shuffle()
    }
        
    func startTimerWithEndMessage(type: MessageEnum, time: Int) {
        
    }
    
    func findPlayer(byName playerName: String, from players: [Player]) -> Player? {
        for player in players {
            if player.id.displayName == playerName {
                return player
            }
        }
        return nil
    }
    
    func playMatch() {
        // Set Players
        for receiver in self.players.elements {
            for userToSend in self.players.elements + [self.himself] {
                if receiver != userToSend {
                    let user = userToSend.convertToUser()
                    self.comms.sendMessage(
                        to: [receiver.id],
                        message: Message(.startMatch, user: user)
                    )
                }
            }
        }
        self.delegate?.didStartMatch(users: self.players.getUsers())
        // Set players' card
        self.makeDeck()
        for player in self.players.elements {
            let cards = self.deck.getCards()
            player.setCards(cards: cards)
            let user = player.convertToUser()
            self.comms.sendMessage(to: [player.id], message: Message(.resCards, user: user))
        }
        let cards = self.deck.getCards()
        self.himself.setCards(cards: cards)
        self.delegate?.didReceiveCards(cards: self.himself.cards!)
        // Bet
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startBet)
        )
        self.delegate?.didStartBet()
        
        var timerCounter = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.comms.sendMessage(
                to: self.players.getAvailableMCPeerIDs(),
                message: Message(.timer, amount: self.time - timerCounter)
            )
            self.delegate?.didReceiveTimer(timer: self.time - timerCounter)
            timerCounter = timerCounter + 1
            if timerCounter == self.time {
                // Timer ends
                timer.invalidate()
                self.comms.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.stopBet)
                )
                self.delegate?.didStopBet()
                
                // Change status to the players whose didn't bet
                for player in self.players.elements {
                    if player.bid == 0 {
                        player.status = .fold
                    }
                }
                if self.himself.bid == 0 {
                    self.himself.status = .fold
                }
                
                // FixBid
                self.comms.sendMessage(
                    to: self.players.getAvailableMCPeerIDs(),
                    message: Message(.startFixBid)
                )
                self.delegate?.didStartFixBid(maxBid: self.maxBid)
                timerCounter = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    self.comms.sendMessage(
                        to: self.players.getAvailableMCPeerIDs(),
                        message: Message(.timer, amount: self.time - timerCounter)
                    )
                    self.delegate?.didReceiveTimer(timer: self.time - timerCounter)
                    timerCounter = timerCounter + 1
                    if timerCounter == self.time {
                        // Timer ends
                        timer.invalidate()
                        self.comms.sendMessage(
                            to: self.players.getAvailableMCPeerIDs(),
                            message: Message(.stopFixBid)
                        )
                        self.delegate?.didStopFixBid()

                    }
                }
            }
        }
    }
    
    // MARK: Game
    func playGame() {
        self.comms.sendMessage(
            to: self.players.getAvailableMCPeerIDs(),
            message: Message(.startGame, amount: self.points)
        )
        self.delegate?.didStartGame(player: self.himself)
        
        self.playMatch()


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
extension Dealer: ServerDelegate {
    
    func didDisconnectWith(peerID: MCPeerID) {
        // TODO: Remove from players the disconnected player
    }
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .bet:
            // Add the bid of the player with peerID
            print("bet")
            let bid = message.user!.bid
            self.totalBid = self.totalBid + bid
            if bid > self.maxBid {
                self.maxBid = bid
            }
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
//        case .cards:
//            // Change the picked cards of the player with peerID
//            print("pickCards")
//            if let cards = message.cards {
//                let player = self.activePlayers.findPlayerWith(peerID: peerID)
//                player?.cards = cards
//            } else {
//                print("Message .pickCards has nil cards")
//            }
            
        case .reqPlayer:
            print("reqPlayer")
            var user = message.user!
            let player = self.findPlayer(byName: user.name, from: self.players.elements + [self.himself])!
            user = player.convertToUser()
            self.comms.sendMessage(to: [peerID], message: Message(.resPlayer, user: user))
            
        default:
            print("MessageType \(message.type) not allowed")
        }
    }
    
}
