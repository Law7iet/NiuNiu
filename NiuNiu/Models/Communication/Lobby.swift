//
//  Lobby.swift
//  NiuNiu
//
//  Created by Han Chu on 18/07/22.
//

import MultipeerConnectivity

/// The class that keeps data of the MCPeerID in the session during the match-making.
/// Every lobby must have an user.
class Lobby {
    
    // MARK: Properties
    /// The user's PeerID who is in the lobby.
    var user: MCPeerID
    /// The users' PeerID in the lobby
    var users: [MCPeerID]
    var count: Int {
        get {
            return self.users.count
        }
    }
    
    // MARK: Methods
    init(user: MCPeerID) {
        self.user = user
        self.users = [user]
    }
    
    // MARK: Supporting Functions
    func getIndex(ofUser peerID: MCPeerID) -> Int? {
        return self.users.firstIndex(of: peerID)
    }
    
    func getUser(byName name: String) -> MCPeerID? {
        for user in self.users {
            if user.displayName == name {
                return user
            }
        }
        return nil
    }

    
    func addUser(withPeerID peerID: MCPeerID) {
        self.users.append(peerID)
    }
    
    func removeUser(withIndex index: Int) {
        self.users.remove(at: index)
    }
    
    func clearUsers(withPeers users: [MCPeerID]) {
        self.users = users
    }
    
    func getUserNames() -> [String] {
        var array = [String]()
        for user in self.users {
            array.append(user.displayName)
        }
        return array
    }
    
}
