//
//  LobbyManager.swift
//  NiuNiu
//
//  Created by Han Chu on 09/07/22.
//

import MultipeerConnectivity

protocol ClientDelegate {
    
    func didConnectWith(peerID: MCPeerID)
    func didDisconnectWith(peerID: MCPeerID)
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data)
    
}

class Client: NSObject {
    
    var session: MCSession
    var delegate: ClientDelegate?
    
    init(session: MCSession) {
        self.session = session
        super.init()
        self.session.delegate = self
    }
    
    // MARK: Session's methods
    func disconnectSession() {
        self.session.disconnect()
    }
    
    func sendMessageTo(_ user: MCPeerID, message: Message) {
        if let data = message.convertToData() {
            do {
                try self.session.send(data, toPeers: [user], with: .reliable)
            } catch {
                print("ServerManager.sendMessage error")
            }
        }
    }
    
}

extension Client: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("ClientManager connected: \(peerID.displayName)")
            delegate?.didConnectWith(peerID: peerID)
        case MCSessionState.connecting:
            print("ClientManager Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("ClientManager Not connected: \(peerID.displayName)")
            delegate?.didDisconnectWith(peerID: peerID)
        @unknown default:
            print("ClientManager Unknown state: \(state)")
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
