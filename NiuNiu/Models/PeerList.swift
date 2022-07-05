//
//  PeerList.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import MultipeerConnectivity

class PeerList {
    var list: [MCPeerID]
    
    init() {
        self.list = [MCPeerID]()
    }
    
    func convertListToString() -> [String] {
        var peerList = [String]()
        for el in list {
            peerList.append(el.displayName)
        }
        return peerList
    }
}
