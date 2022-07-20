//
//  Client.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

// MARK: Client's protocols
protocol ClientSearchDelegate {
    func didFindHostWith(peerID: MCPeerID)
    func didLoseHostWith(peerID: MCPeerID)
}

protocol ClientLobbyDelegate {
    func didConnectWith(peerID: MCPeerID)
    func didDisconnectWith(peerID: MCPeerID)
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data)
}

protocol ClientDelegate {
    // TODO: Need those 2 functions?
    func didConnectWith(peerID: MCPeerID)
    func didDisconnectWith(peerID: MCPeerID)
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data)
}

class Client: NSObject {
    
    // MARK: Properties
    var session: MCSession
    var browser: MCNearbyServiceBrowser
    var himselfPeerID: MCPeerID
    var hostPeerID: MCPeerID?
    // Delegates
    var searchDelegate: ClientSearchDelegate?
    var lobbyDelegate: ClientLobbyDelegate?
    var clientDelegate: ClientDelegate?
    
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
        self.himselfPeerID = peerID
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
            timeout: 30
        )
    }
    
    func disconnect() {
        self.session.disconnect()
    }
    
    /// Send a message to the server.
    /// The server MCPeerID is saved in the client object when the client connects to the server.
    /// - Parameter msg: The message to send.
    func sendMessageToServer(message msg: Message) {
        if self.hostPeerID != nil {
            if let data = msg.convertToData() {
                do {
                    try self.session.send(
                        data,
                        toPeers: [self.hostPeerID!],
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
    
    
    /// Send a message to the user with MCPeerID passed by parameter.
    /// - Parameters:
    ///   - user: The receiver's MCPeerID.
    ///   - msg: The message.
    func sendMessage(to user: MCPeerID, message msg: Message) {
        if let data = msg.convertToData() {
            do {
                try self.session.send(
                    data,
                    toPeers: [user],
                    with: .reliable
                )
            } catch {
                print("Client.sendMessage - self.session.send error")
            }
        } else {
            print("Client.sendMessage - data == nil")
        }
    }
    
}

extension Client: MCNearbyServiceBrowserDelegate {
    
    // A host is found
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.searchDelegate?.didFindHostWith(peerID: peerID)
    }
    
    // A host is disappeared
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.searchDelegate?.didLoseHostWith(peerID: peerID)
    }
    
}

extension Client: MCSessionDelegate {
    
    // Connections status
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Client connected: \(peerID.displayName)")
            self.lobbyDelegate?.didConnectWith(peerID: peerID)
        case MCSessionState.connecting:
            print("Client Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Client Not connected: \(peerID.displayName)")
            self.lobbyDelegate?.didDisconnectWith(peerID: peerID)
            self.clientDelegate?.didDisconnectWith(peerID: peerID)
            if self.hostPeerID == peerID {
                self.hostPeerID = nil
            }
        @unknown default:
            print("Client Unknown state: \(state)")
        }
    }
    
    // Receive data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = Message(data: data)
        if message.type != .error {
            self.clientDelegate?.didReceiveMessageFrom(sender: peerID, messageData: data)
            self.lobbyDelegate?.didReceiveMessageFrom(sender: peerID, messageData: data)
        } else {
            print("Client.session - message.type == .error from \(peerID.displayName)")
        }
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

