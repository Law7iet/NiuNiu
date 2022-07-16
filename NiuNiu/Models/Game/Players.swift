//
//  Players.swift
//  NiuNiu
//
//  Created by Han Chu on 16/07/22.
//

import MultipeerConnectivity

class Players {
    var list: [Player]
    
    init(players: [Player]) {
        self.list = players
    }
    
    init(players: [MCPeerID], points: Int?) {
        self.list = [Player]()
        for player in players {
            self.list.append(Player(id: player, points: nil))
        }
    }
    
    func getMCPeersID() -> [MCPeerID] {
        var peerList = [MCPeerID]()
        for player in self.list {
            peerList.append(player.id)
        }
        return peerList
    }
    
    func findPlayerWith(peerID: MCPeerID) -> Player? {
        for player in self.list {
            if player.id == peerID {
                return player
            }
        }
        return nil
    }
    
    func findActivePlayers() {
        var index = 0
        while(index < self.list.count) {
            if self.list[index].status == .fold {
                self.list.remove(at: index)
            } else {
                index = index + 1
            }
        }
    }

}
