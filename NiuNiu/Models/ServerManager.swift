//
//  ServerManager.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ServerManagerDelegate {
    func didConnected(who peerID: MCPeerID)
    func didDisconnected(who peerID: MCPeerID)
    func didReciveMessage(from peerID: MCPeerID, what data: Data)
}

class ServerManager: NSObject {
    
    var myPeerID: MCPeerID!
    var playersPeerID: [MCPeerID]!
    var mcSession: MCSession!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    var delegate: ServerManagerDelegate?
    
    override init() {
        self.myPeerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(Utils.getRandomID(length: 4))")
        self.playersPeerID = [MCPeerID]()
        self.mcSession = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: nil, serviceType: "niu-niu-game")
        
        super.init()
        self.mcSession.delegate = self
        self.mcNearbyServiceAdvertiser.delegate = self
    }
    
    func startAdvertising() {
        self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        self.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func getPlayersInLobby() -> [MCPeerID] {
        return [self.myPeerID] + self.playersPeerID
    }
    
    func getNumberOrPlayers() -> Int {
        return self.playersPeerID.count + 1
    }
    
    func addPlayer(peerID: MCPeerID) {
        self.playersPeerID.append(peerID)
    }
    
    func removePlayer(peerID: MCPeerID) {
        if let index = self.playersPeerID.firstIndex(of: peerID) {
            self.playersPeerID.remove(at: index)
        }
    }
    
    func sendBroadcastMessage(message: Message) {
        if let data = message.convertToData() {
            do {
                try self.mcSession.send(data, toPeers: self.playersPeerID, with: .reliable)
            } catch {
                print("ServerManager.sendBroadcastMessage error")
            }
        }
    }
    
    func sendMessageTo(who user: MCPeerID, message: Message) {
        if let data = message.convertToData() {
            do {
                try self.mcSession.send(data, toPeers: [user], with: .reliable)
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
            self.delegate?.didConnected(who: peerID)
        case MCSessionState.connecting:
            print("ServerManager Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("ServerManager Not connected: \(peerID.displayName)")
            self.delegate?.didDisconnected(who: peerID)
        @unknown default:
            print("ServerManager Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.didReciveMessage(from: peerID, what: data)
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

extension ServerManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.mcSession)
    }
    
}
