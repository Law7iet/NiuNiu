//
//  Server.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ServerGameDelegate {
    func didDisconnect(with: MCPeerID)
    func didReceiveMessage(from peerID: MCPeerID, messageData: Data)
}

class Server: NSObject {
    
    // MARK: Properties
    var session: MCSession
    var advertiser: MCNearbyServiceAdvertiser
    var peerID: MCPeerID
    var clientsPeerIDs: [MCPeerID]
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
        self.clientsPeerIDs = [MCPeerID]()
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
                try self.session.send(
                    data,
                    toPeers: users,
                    with: .reliable
                )
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
            self.clientsPeerIDs.append(peerID)
        case MCSessionState.notConnected:
            if let index = self.clientsPeerIDs.firstIndex(of: peerID) {
                self.clientsPeerIDs.remove(at: index)
            }
        default:
            break
        }
    }
    
    // Receive data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.gameDelegate?.didReceiveMessage(from: peerID, messageData: data)
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}
