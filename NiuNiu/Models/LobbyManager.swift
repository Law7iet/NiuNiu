//
//  LobbyManager.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ClientManagerDelegate {
    func didConnected(who peerID: MCPeerID)
    func didDisconnected(who peerID: MCPeerID)

    func didReciveMessage(from peerID: MCPeerID, what data: Data)
}

class LobbyManager: NSObject {
    
    var myPeerID: MCPeerID
    var hostPeerID: MCPeerID
    var playersPeerID: [MCPeerID]
    var mcSession: MCSession
    var delegate: ClientManagerDelegate?
    
    init(peerID: MCPeerID, hostPeerID: MCPeerID, mcSession: MCSession) {
        self.myPeerID = peerID
        self.hostPeerID = hostPeerID
        self.playersPeerID = [MCPeerID]()
        self.mcSession = mcSession
        
        super.init()
        
        self.mcSession.delegate = self
    }
    
    func getPlayersInLobby() -> [MCPeerID] {
        return [self.myPeerID] + self.playersPeerID
    }
    
    func getNumberOfPlayers() -> Int {
        return self.playersPeerID.count + 1
    }
    
    func clearPlayers() {
        self.playersPeerID = [MCPeerID]()
    }
    
    func addPlayer(mcPeerID: MCPeerID) {
        self.playersPeerID.append(mcPeerID)
    }
    
    func getIndexOf(player mcPeerID: MCPeerID) -> Int? {
        return self.playersPeerID.firstIndex(of: mcPeerID)
    }
    
    func removePlayerWith(index: Int) {
        self.playersPeerID.remove(at: index)
    }
    
    func disconnectSession() {
        self.mcSession.disconnect()
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

extension LobbyManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("ClientManager connected: \(peerID.displayName)")
            // Add the connected player
            delegate?.didConnected(who: peerID)
        case MCSessionState.connecting:
            print("ClientManager Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("ClientManager Not connected: \(peerID.displayName)")
            // Remove the disconnected player
            delegate?.didDisconnected(who: peerID)
        @unknown default:
            print("ClientManager Unknown state: \(state)")
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
