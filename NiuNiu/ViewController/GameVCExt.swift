//
//  GameVCExt.swift
//  NiuNiu
//
//  Created by Han Chu on 17/08/22.
//

import MultipeerConnectivity

// MARK: ClientGameDelegate implementation
// This is used for the UI changes caused by the connections during the gameplay
// It could be the disconnection of a peer or the receiving of a message from the server
extension GameVC: PlayerDelegate {
    
    func didDisconnect(with peerID: MCPeerID) {
        
        let handler = { (action: UIAlertAction) in
            self.forceGameOver = true
            self.player.client.disconnect()
            self.dealer?.timer?.invalidate()
            self.dealer?.server.disconnect()
            self.performSegue(withIdentifier: "showEndSegue", sender: Any?.self)
        }
        
        if self.player.client.session.connectedPeers.count == 1 {
            // Insufficient players in the lobby
            let alert = UIAlertController(
                title: "Exit from lobby",
                message: "Insufficient number of players",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Ok",
                style: .default,
                handler: handler
            ))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        } else {
            if peerID == self.player.client.serverPeerID {
                // Server disconnected
                var alert: UIAlertController
                if self.dealer == nil {
                    // Server disconnected from a guest
                    alert = UIAlertController(
                        title: "Exit from lobby",
                        message: Utils.hostLeftMessage,
                        preferredStyle: .alert
                    )
                } else {
                    // Server disconnected from the host
                    alert = UIAlertController(
                        title: "Exit from lobby",
                        message: Utils.clientLeftMessage,
                        preferredStyle: .alert
                    )
                }
                alert.addAction(UIAlertAction(
                    title: "Ok",
                    style: .default,
                    handler: handler
                ))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            } else {
                // Player disconnected
                DispatchQueue.main.async {
                    for btn in self.playersButtons {
                        if btn.title(for: UIControl.State.normal) == peerID.displayName {
                            btn.isEnabled = false
                        }
                    }
                }
            }
        }
    }
    
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        // MARK: StartMatch
        case .startMatch:
            DispatchQueue.main.async {
                // Initialization of data
                self.time = message.amount!
                self.maxBid = 0
                self.totalBid = 0
                self.users = message.users!
                self.setupPlayers()
                // Initialization of UI
                self.statusLabel.text = "The game will start soon"
                self.timerLabel.text = String(Utils.timerShort)
                self.betSlider.maximumValue = Float(self.player.points)
                for btn in self.playersButtons + self.cardsButtons {
                    btn.isHidden = true
                }
                // Start the timer
                var timerCounter = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(Utils.timerShort - timerCounter)
                    if timerCounter == Utils.timerShort {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Match started!"
                        self.timerLabel.text = ""
                        for btn in self.playersButtons + self.cardsButtons {
                            btn.isHidden = false
                        }
                    }
                }
            }
        // MARK: StartBet
        case .startBet:
            DispatchQueue.main.async {
                // Change data
                self.player.status = .bet
                self.isClicked = false
                // Change UI
                self.statusLabel.text = "Start Bet!"
                self.timerLabel.text = String(self.time)
                self.actionButton.setAttributedTitle(
                    Utils.myString("Bet (1)"),
                    for: .normal
                )
                self.setupUserButton(withSlider: true, turnOn: true)
                // Set timer
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(self.time - timerCounter)
                    if timerCounter == self.time {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Stop Bet!"
                        self.timerLabel.text = ""
                        self.setupUserButton(withSlider: true, turnOn: false)
                    }
                }
            }
        // MARK: StopBet
        case .stopBet:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                if (self.isClicked == false || self.player.bid == 0) && message.amount == 0 {
                    // The player didn't bet
                    self.foldAction()
                }
                // Change UI
                self.statusLabel.text = "Stop Bet!"
                self.timerLabel.text = ""
                self.setupUserButton(withSlider: true, turnOn: false)
            }
        // MARK: StartCheck
        case .startCheck:
            DispatchQueue.main.async {
                // Change UI
                self.statusLabel.text = "Start Check!"
                self.timerLabel.text = String(self.time)
                // Change data
                self.maxBid = message.amount!
                self.isClicked = false
                // Control if player can check/all-in
                if self.player.bid != self.maxBid {
                    let diff = self.maxBid - self.player.bid
                    if diff < self.player.points {
                        // Check
                        self.player.status = self.player.status == .fold ? .fold : .check
                        self.actionButton.setAttributedTitle(
                            Utils.myString("Check +\(diff)"),
                            for: .normal
                        )
                    } else {
                        // All-in
                        self.player.status = self.player.status == .fold ? .fold : .allIn
                        self.actionButton.setAttributedTitle(
                            Utils.myString("All-in"),
                            for: .normal
                        )
                    }
                    // Change UI
                    self.setupUserButton(withSlider: false, turnOn: true)
                }
                // Set timer
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(self.time - timerCounter)
                    if timerCounter == self.time {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Stop Check!"
                        self.timerLabel.text = ""
                        self.setupUserButton(withSlider: false, turnOn: false)
                    }
                }
            }
        // MARK: StopCheck
        case .stopCheck:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                if self.isClicked == false && self.player.status != .didCheck && message.amount == 0 && self.player.bid != self.maxBid {
                    // The player didn't check
                    self.foldAction()
                }
                // Change UI
                self.statusLabel.text = "Stop Check!"
                self.timerLabel.text = ""
                self.setupUserButton(withSlider: false, turnOn: false)
            }
        // MARK: StartCards
        case .startCards:
            DispatchQueue.main.async {
                // Change data
                self.player.status = self.player.status == .fold ? .fold : .cards
                self.isClicked = false
                // Change UI
                self.statusLabel.text = "Start pick cards!"
                self.timerLabel.text = String(self.time)
                self.actionButton.setAttributedTitle(
                    Utils.myString("Pick cards"),
                    for: .normal
                )
                self.setupUserButton(withSlider: false, turnOn: true)
                self.checkPickedCards()
                // Set timer
                var timerCounter = 0
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    timerCounter += 1
                    self.timerLabel.text = String(self.time - timerCounter)
                    if timerCounter == self.time {
                        timer.invalidate()
                        // Change UI
                        self.statusLabel.text = "Stop Cards!"
                        self.timerLabel.text = ""
                        self.setupUserButton(withSlider: false, turnOn: false)
                        for btn in self.cardsButtons {
                            btn.isEnabled = false
                        }
                    }
                }
            }
        // MARK: StopCards
        case .stopCards:
            DispatchQueue.main.async {
                self.timer?.invalidate()
                if self.isClicked == false && message.amount == 0 {
                    // The player didn't pick any cards
                    self.foldAction()
                }
                // Change UI
                self.statusLabel.text = "Stop Cards!"
                self.timerLabel.text = ""
                self.setupUserButton(withSlider: false, turnOn: false)
                for btn in self.cardsButtons {
                    btn.isEnabled = false
                }
            }
        // MARK: EndMatch
        case .endMatch:
            DispatchQueue.main.async {
                self.totalBid = message.amount!
                self.users = message.users!
                self.performSegue(withIdentifier: "showEndSegue", sender: nil)
            }
        // MARK: resPlayer
        case .resPlayer:
            // Update the UI
            DispatchQueue.main.async {
                self.userData?.message = "Points: \(message.users![0].points)\nBid: \(message.users![0].bid)"
                self.userDataSpinner?.stopAnimating()
            }
        // MARK: notify
        case .notify:
            if let player = message.users?[0] {
                if player.id != self.player.client.peerID.displayName {
                    DispatchQueue.main.async {
                        // Find the player's index
                        for index in 0 ..< 4 {
                            // Compute the message
                            if self.playersButtons[index].currentAttributedTitle?.string == player.id {
                                var message = ""
                                switch player.status {
                                case .didBet: message = "Bet \(player.bid)"
                                case .didCheck: message = "Checked"
                                case .didCards: message = "Cards confirmed"
                                default: break
                                }
                                self.playersLabel[index].text = message
                                // Animation
                                UIView.transition(with: self.playersLabel[index], duration: 0.5, options: .transitionCrossDissolve) {
                                    self.playersLabel[index].isHidden = false
                                }
                                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
                                    UIView.transition(with: self.playersLabel[index], duration: 0.5, options: .transitionCrossDissolve) {
                                        self.playersLabel[index].isHidden = true
                                    }
                                    timer.invalidate()
                                }
                            }
                        }
                    }
                }
            } else {
                print("ClientGameVC.didReceiveMessage - empty players")
            }
        default:
            print("ClientGameVC.didReceiveMessage - message.type == \(message.type)")
        }
    }
    
}
