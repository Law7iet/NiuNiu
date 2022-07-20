//
//  Server.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

// MARK: Server's protocols
protocol ServerLobbyDelegate {
    func didConnectWith(peerID: MCPeerID)
    func didDisconnectWith(peerID: MCPeerID)
}

protocol ServerDelegate {
    func didDisconnectWith(peerID: MCPeerID)
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data)
}


class Server: NSObject {
    
    // MARK: Properties
    var session: MCSession
    var advertiser: MCNearbyServiceAdvertiser
    var himselfPeerID: MCPeerID
    var connectedPeerIDs: [MCPeerID]
    // Delegates
    var lobbyDelegate: ServerLobbyDelegate?
    var serverDelegate: ServerDelegate?
    
    // MARK: Methods
    init(peerID: MCPeerID) {
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "niu-niu-game")
        self.himselfPeerID = peerID
        self.connectedPeerIDs = [MCPeerID]()
        super.init()
        self.session.delegate = self
        self.advertiser.delegate = self
    }
    
    // MARK: Advertise's methods
    func startAdvertising() {
        self.advertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        self.advertiser.stopAdvertisingPeer()
    }
    
    // MARK: Session's methods
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
                try self.session.send(data, toPeers: users, with: .reliable)
            } catch {
                print("Server.sendMessage - self.session.send error")
            }
        } else {
            print("Server.sendMessage - data == nil")
        }
    }
}

extension Server: MCNearbyServiceAdvertiserDelegate {
    
    // Receive connection
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    
}

extension Server: MCSessionDelegate {
    
    // Connection status
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Server connected: \(peerID.displayName)")
            self.connectedPeerIDs.append(peerID)
            self.lobbyDelegate?.didConnectWith(peerID: peerID)
        case MCSessionState.connecting:
            print("Server Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Server Not connected: \(peerID.displayName)")
            if let index = self.connectedPeerIDs.firstIndex(of: peerID) {
                self.connectedPeerIDs.remove(at: index)
            } else {
                print("Server.session - disconnected peerID wasn't in self.connectedPeerIDs")
            }
            self.lobbyDelegate?.didDisconnectWith(peerID: peerID)
        @unknown default:
            print("Server Unknown state: \(state)")
        }
    }
    
    // Receive data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.serverDelegate?.didReceiveMessageFrom(sender: peerID, messageData: data)
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}
