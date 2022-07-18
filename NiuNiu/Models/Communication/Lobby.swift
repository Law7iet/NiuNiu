//
//  Lobby.swift
//  NiuNiu
//
//  Created by Han Chu on 18/07/22.
//

import MultipeerConnectivity

class Lobby {
    
    /// The own PeerID
    var myPeerID: MCPeerID!
    /// The host PeerID
    var hostPeerID: MCPeerID!
    /// The users in the lobby's PeerID, included the host and himself
    var usersPeerID: [MCPeerID]
    var count: Int {
        get {
            self.usersPeerID.count
        }
    }
    
    init(himself: MCPeerID) {
        self.myPeerID = himself
        self.usersPeerID = [himself]
    }
    
    init(himself: MCPeerID, host: MCPeerID) {
        self.myPeerID = himself
        self.hostPeerID = host
        if himself == host {
            self.usersPeerID = [himself]
        } else {
            self.usersPeerID = [host, himself]
        }
    }
    
    // MARK: Methods
    func getIndex(ofPlayer peerID: MCPeerID) -> Int? {
        return self.usersPeerID.firstIndex(of: peerID)
    }
    
    func addUser(withPeerID peerID: MCPeerID) {
        self.usersPeerID.append(peerID)
    }
    
    func removeUser(withIndex index: Int) {
        self.usersPeerID.remove(at: index)
    }
    
    /// Get all the users' name as String.
    /// - Returns: The users' name.
    func getUsersName() -> [String] {
        var array = [String]()
        for player in self.usersPeerID {
            array.append(player.displayName)
        }
        return array
    }
    
    // MARK: Server Methods
    /// Get all the MCPeerIDs used by the server to send a broadcast message.
    /// It's excluded the host's MCPeerID and himself's MCPeerID.
    /// - Returns: The MCPeerIDs of the broadcast message.
    func getSendablePeersID() -> [MCPeerID] {
        var array = [MCPeerID]()
        for player in self.usersPeerID {
            if player != self.myPeerID && player != self.hostPeerID {
                array.append(player)
            }
        }
        return array
    }
    
    // MARK: Search Methods
    /// Clear userPeerIDs but keeps the others properties
    func clearHosts() {
        self.usersPeerID.removeAll()
    }
    
    // MARK: Client Methods
    /// Clear the userPeerIDs except for himself
    func clearPlayers() {
        self.usersPeerID = [self.myPeerID]
    }

}
