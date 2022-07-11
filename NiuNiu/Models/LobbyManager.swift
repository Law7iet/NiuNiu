//
//  LobbyManager.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ClientManagerDelegate {
    func didConnectedWith(peerID: MCPeerID)
    func didDisconnectedWith(peerID: MCPeerID)
    func didReciveMessageFrom(sender peerID: MCPeerID, messageData data: Data)
}

class LobbyManager: NSObject {
    
    var myPeerID: MCPeerID
    var hostPeerID: MCPeerID
    var playersPeerID: [MCPeerID]
    var session: MCSession
    var delegate: ClientManagerDelegate?
    
    init(peerID: MCPeerID, hostPeerID: MCPeerID, session: MCSession) {
        self.myPeerID = peerID
        self.hostPeerID = hostPeerID
        self.playersPeerID = [MCPeerID]()
        self.session = session
        super.init()
        self.session.delegate = self
    }
    
    // MARK: Players' methods
    func getPlayersInLobby() -> [MCPeerID] {
        return [self.myPeerID] + self.playersPeerID
    }
    
    func getNumberOfPlayers() -> Int {
        return self.playersPeerID.count + 1
    }
    
    func getIndexOf(player peerID: MCPeerID) -> Int? {
        return self.playersPeerID.firstIndex(of: peerID)
    }
    
    func addPlayerWith(peerID: MCPeerID) {
        self.playersPeerID.append(peerID)
    }
    
    func removePlayerWith(index: Int) {
        self.playersPeerID.remove(at: index)
    }
    
    func clearPlayersInLobby() {
        self.playersPeerID.removeAll()
    }
    
    // MARK: Session's methods
    func disconnectSession() {
        self.session.disconnect()
    }
    
    func sendMessageTo(receiver user: MCPeerID, message: Message) {
        if let data = message.convertToData() {
            do {
                try self.session.send(data, toPeers: [user], with: .reliable)
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
            delegate?.didConnectedWith(peerID: peerID)
        case MCSessionState.connecting:
            print("ClientManager Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("ClientManager Not connected: \(peerID.displayName)")
            // Remove the disconnected player
            delegate?.didDisconnectedWith(peerID: peerID)
        @unknown default:
            print("ClientManager Unknown state: \(state)")
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
