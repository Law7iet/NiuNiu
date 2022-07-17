//
//  ServerManager.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol HostManagerDelegate {
    
    func didConnectWith(peerID: MCPeerID)
    func didDisconnectWith(peerID: MCPeerID)
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data)

}

class HostManager: NSObject {
    
    /// The host's MCPeerID
    var myPeerID: MCPeerID
    /// The list of the guests in the lobby except himself (the host)
    var playersPeerID: [MCPeerID]
    var session: MCSession
    var advertiser: MCNearbyServiceAdvertiser
    
    var delegate: HostManagerDelegate?
    
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
    /// Returns the list of the all the players in the lobby, included himself (the host is also a player) in the first position of the list
    /// - Returns: the list of all the players in the lobby
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
    
    func sendMessageTo(receivers peersID: [MCPeerID], message: Message) {
        if let data = message.convertToData() {
            do {
                try self.session.send(data, toPeers: peersID, with: .reliable)
            } catch {
                print("ServerManager.sendMessage error")
            }
        }
    }
}

extension HostManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("ServerManager connected: \(peerID.displayName)")
            self.delegate?.didConnectWith(peerID: peerID)
        case MCSessionState.connecting:
            print("ServerManager Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("ServerManager Not connected: \(peerID.displayName)")
            self.delegate?.didDisconnectWith(peerID: peerID)
        @unknown default:
            print("ServerManager Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.didReceiveMessageFrom(sender: peerID, messageData: data)
    }
    
    // Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

extension HostManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    
}
