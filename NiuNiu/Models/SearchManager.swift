//
//  SearchManager.swift
//  NiuNiu
//
//  Created by Han Chu on 10/07/22.
//

import MultipeerConnectivity

protocol SearchManagerDelegate {
    func didFoundAHost(who peerID: MCPeerID)
    func didLostAHost(who peerID: MCPeerID)
}

class SearchManager: NSObject {
    
    var myPeerID: MCPeerID
    var hostsPeerID: [MCPeerID]
    var mcSession: MCSession
    var mcNearbyServiceBrowser: MCNearbyServiceBrowser
    var delegate: SearchManagerDelegate?
    
    override init() {
        self.myPeerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(Utils.getRandomID(length: 4))")
        self.hostsPeerID = [MCPeerID]()
        self.mcSession = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcNearbyServiceBrowser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: "niu-niu-game")
    
        super.init()
        
        self.mcNearbyServiceBrowser.delegate = self
    }
    
    func startBrowsing() {
        self.mcNearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        self.mcNearbyServiceBrowser.stopBrowsingForPeers()
    }

    func getNumberOfHosts() -> Int {
        return self.hostsPeerID.count
    }
    
    func clearHosts() {
        self.hostsPeerID = [MCPeerID]()
    }
    
    func addHost(peerID: MCPeerID) {
        self.hostsPeerID.append(peerID)
    }
    
    func removeHost(peerID: MCPeerID) {
        if let index = self.hostsPeerID.firstIndex(of: peerID) {
            self.hostsPeerID.remove(at: index)
        }
    }
    
    func disconnectSession() {
        self.mcSession.disconnect()
    }
    
    func requestToJoin(host peerID: MCPeerID) {
        self.mcNearbyServiceBrowser.invitePeer(
            peerID,
            to: self.mcSession,
            withContext: nil,
            timeout: 30
        )
    }
    
}

extension SearchManager: MCNearbyServiceBrowserDelegate {
    
    // A host is found
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.delegate?.didFoundAHost(who: peerID)
    }
    
    // A host is disappeared
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.didLostAHost(who: peerID)
    }
    
}
