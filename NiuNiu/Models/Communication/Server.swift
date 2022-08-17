//
//  Server.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ServerGameDelegate {
    func didDisconnect(with peerID: MCPeerID)
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data)
}

class Server: NSObject {
    
    // MARK: Properties
    var session: MCSession
    var advertiser: MCNearbyServiceAdvertiser
    var peerID: MCPeerID
    var connectedPeers: [MCPeerID] {
        self.session.connectedPeers
    }
    // Delegates
    var gameDelegate: ServerGameDelegate?
    
    // MARK: Methods
    init(peerID: MCPeerID) {
        self.session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        self.advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: "niu-niu-game"
        )
        self.peerID = peerID
        super.init()
        self.session.delegate = self
        self.advertiser.delegate = self
    }
    
    // MARK: Advertise's methods
    /// It opens the server's advertiser
    func startAdvertising() {
        self.advertiser.startAdvertisingPeer()
    }
    
    /// It closes the server's advertiser
    func stopAdvertising() {
        self.advertiser.stopAdvertisingPeer()
    }
    
    // MARK: Session's methods
    /// It disconnects the server with the clients
    func disconnect() {
        self.session.disconnect()
    }
    
    /// Send a message to the users with MCPeerID passed by parameter.
    /// - Parameters:
    ///   - users: The receivers' MCPeerID.
    ///   - msg: The message.
    func sendMessage(to users: [MCPeerID], message msg: Message) {
        if let data = msg.convertToData() {
            do {
                try self.session.send(
                    data,
                    toPeers: users,
                    with: .reliable
                )
            } catch {
                print("Server.sendMessage - self.session.send error")
                print(error)
            }
        } else {
            print("Server.sendMessage - empty data")
        }
    }
}

extension Server: MCNearbyServiceAdvertiserDelegate {
    
    // Receive connection
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if self.session.connectedPeers.count < Settings.numberOfPlayers {
            invitationHandler(true, self.session)
        } else {
            invitationHandler(false, nil)
        }
    }
    
}

extension Server: MCSessionDelegate {
    
    // Connection status
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Server connected with \(peerID.displayName)")
            self.sendMessage(to: [peerID], message: Message(.maxPlayers, amount: Settings.numberOfPlayers))
        case MCSessionState.connecting:
            print("Server connecting with \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Server disconnected with \(peerID.displayName)")
            self.gameDelegate?.didDisconnect(with: peerID)
        @unknown default:
            break
        }
    }
    
    // Receive data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.gameDelegate?.didReceiveMessage(from: peerID, messageData: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}
