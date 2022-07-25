//
//  Players.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

import MultipeerConnectivity

class Players {
    var elements: [Player]
    
    init(players: [Player]) {
        self.elements = players
    }
    
    init(players: [MCPeerID], points: Int?) {
        self.elements = [Player]()
        for player in players {
            self.elements.append(Player(id: player, points: nil))
        }
    }
    
    subscript(index: Int) -> Player {
        return self.elements[index]
    }
    
    /// Get an array of MCPeerID of the players in the class with .fold status.
    /// This is the list of the players that the Server has to send a message.
    /// - Returns: The array of MCPeerID
    func getAvailableMCPeerIDs() -> [MCPeerID] {
        var peerList = [MCPeerID]()
        for player in self.elements {
            if player.status != .fold {
                peerList.append(player.id)
            }
        }
        return peerList
    }

}
