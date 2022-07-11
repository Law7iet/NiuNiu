//
//  ServerManager.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ServerManagerDelegate {
    func didConnectedWith(peerID: MCPeerID)
    func didDisconnectedWith(peerID: MCPeerID)
    func didReciveMessageFrom(sender peerID: MCPeerID, messageData data: Data)
}

class ServerManager: NSObject {
    
    var myPeerID: MCPeerID
    var playersPeerID: [MCPeerID]
    var session: MCSession
    var advertiser: MCNearbyServiceAdvertiser
    var delegate: ServerManagerDelegate?
    
    override init() {
        self.myPeerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(Utils.getRandomID(length: 4))")
        self.playersPeerID = [MCPeerID]()
        self.session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: nil, serviceType: "niu-niu-game")
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
    
    // MARK: Players' methods
    func getPlayersInLobby() -> [MCPeerID] {
        return [self.myPeerID] + self.playersPeerID
    }
    
    func getNumberOfPlayers() -> Int {
        return self.playersPeerID.count + 1
    }
    
    func getIndexOf(player mcPeerID: MCPeerID) -> Int? {
        return self.playersPeerID.firstIndex(of: mcPeerID)
    }
    
    func addPlayerWith(peerID: MCPeerID) {
        self.playersPeerID.append(peerID)
    }
    
    func removePlayerWith(index: Int) {
        self.playersPeerID.remove(at: index)
    }
    
    // MARK: Session's methods
    func disconnectSession() {
        self.session.disconnect()
    }
    
    func sendBroadcastMessage(_ message: Message) {
        if let data = message.convertToData() {
            do {
                try self.session.send(data, toPeers: self.playersPeerID, with: .reliable)
            } catch {
                print("ServerManager.sendBroadcastMessage error")
            }
        }
    }
    
    func sendMessageTo(receiver peerID: MCPeerID, message: Message) {
        if let data = message.convertToData() {
            do {
                try self.session.send(data, toPeers: [peerID], with: .reliable)
            } catch {
                print("ServerManager.sendMessage error")
            }
        }
    }
}

extension ServerManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("ServerManager connected: \(peerID.displayName)")
            self.delegate?.didConnectedWith(peerID: peerID)
        case MCSessionState.connecting:
            print("ServerManager Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("ServerManager Not connected: \(peerID.displayName)")
            self.delegate?.didDisconnectedWith(peerID: peerID)
        @unknown default:
            print("ServerManager Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.didReciveMessageFrom(sender: peerID, messageData: data)
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

extension ServerManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    
}
