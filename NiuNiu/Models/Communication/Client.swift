//
//  Client.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

// MARK: Client's protocols
protocol ClientSearchDelegate {
    func didFindHost(with peerID: MCPeerID)
    func didLoseHost(with peerID: MCPeerID)
    func didHostAccept(_ peerID: MCPeerID, maxPlayers: Int)
}

protocol ClientLobbyDelegate {
    func didConnect(with peerID: MCPeerID)
    func didDisconnect(with peerID: MCPeerID)
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data)
}

protocol ClientGameDelegate {
    func didDisconnect(with peerID: MCPeerID)
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data)
}

protocol ClientEndDelegate {
    func didDisconnect(with peerID: MCPeerID)
}

class Client: NSObject {
    
    // MARK: Properties
    var session: MCSession
    var browser: MCNearbyServiceBrowser
    var peerID: MCPeerID
    var serverPeerID: MCPeerID?
    // Delegates
    var searchDelegate: ClientSearchDelegate?
    var lobbyDelegate: ClientLobbyDelegate?
    var gameDelegate: ClientGameDelegate?
    var endDelegate: ClientEndDelegate?
    
    // MARK: Methods
    init(peerID: MCPeerID) {
        self.session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        self.browser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: "niu-niu-game"
        )
        self.peerID = peerID
        super.init()
        self.browser.delegate = self
        self.session.delegate = self
    }
    
    // MARK: Browser's methods
    func startBrowsing() {
        self.browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        self.browser.stopBrowsingForPeers()
    }

    // MARK: Session's methods
    func connect(to peerID: MCPeerID) {
        self.browser.invitePeer(
            peerID,
            to: self.session,
            withContext: nil,
            timeout: Double(Settings.timerShort)
        )
    }
    
    func disconnect() {
        self.session.disconnect()
    }
    
    /// Send a message to the server.
    /// The server MCPeerID is saved in the client object when the client connects to the server.
    /// - Parameter msg: The message to send.
    func sendMessageToServer(message msg: Message) {
        if self.serverPeerID != nil {
            if let data = msg.convertToData() {
                do {
                    try self.session.send(
                        data,
                        toPeers: [self.serverPeerID!],
                        with: .reliable
                    )
                } catch {
                    print("Client.sendMessageToServer - self.session.send error")
                }
            } else {
                print("Client.sendMessageToServer - data == nil")
            }
        } else {
            print("Client.sendMessageToServer - self.hostPeerID == nil")
        }
    }
        
}

extension Client: MCNearbyServiceBrowserDelegate {
    
    // A host is found
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.searchDelegate?.didFindHost(with: peerID)
    }
    
    // A host is disappeared
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.searchDelegate?.didLoseHost(with: peerID)
    }
    
}

extension Client: MCSessionDelegate {
    
    // Connections status
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            self.lobbyDelegate?.didConnect(with: peerID)
        case MCSessionState.notConnected:
            self.lobbyDelegate?.didDisconnect(with: peerID)
            self.gameDelegate?.didDisconnect(with: peerID)
            self.endDelegate?.didDisconnect(with: peerID)
            if peerID == self.serverPeerID {
                self.serverPeerID = nil
            }
        default:
            break
        }
    }
    
    // Receive data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = Message(data: data)
        if message.type == .maxPlayers {
            // Init message from server
            self.serverPeerID = peerID
            self.searchDelegate?.didHostAccept(peerID, maxPlayers: message.amount!)
        } else if message.type != .error {
            self.lobbyDelegate?.didReceiveMessage(from: peerID, messageData: data)
            self.gameDelegate?.didReceiveMessage(from: peerID, messageData: data)
        } else {
            print("Client.session - message.type == .error from \(peerID.displayName)")
        }
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

