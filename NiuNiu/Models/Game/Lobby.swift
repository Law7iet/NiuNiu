//
//  Lobby.swift
//  NiuNiu
//
//  Created by Han Chu on 18/07/22.
//

import MultipeerConnectivity

class Lobby {
    
    /// The own PeerID
    var myPeerID: MCPeerID
    /// The host PeerID
    var hostPeerID: MCPeerID
    /// The players in the lobby's PeerID, included the host and himself
    var playersPeerID: [MCPeerID]
    
    init(himself: MCPeerID, host: MCPeerID, players: [MCPeerID]) {
        self.myPeerID = himself
        self.hostPeerID = host
        self.playersPeerID = players
    }
    
    // For Server
    func getSendablePeersID() -> [MCPeerID] {
        var array = [MCPeerID]()
        for player in self.playersPeerID {
            if player != self.myPeerID && player != self.hostPeerID {
                array.append(player)
            }
        }
        return array
    }
    
    // For Client
    func getHostPeerID() -> MCPeerID {
        return self.hostPeerID
    }
    
}
