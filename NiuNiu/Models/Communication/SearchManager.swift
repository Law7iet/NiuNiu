//
//  SearchManager.swift
//  NiuNiu
//
//  Created by Han Chu on 10/07/22.
//

import MultipeerConnectivity

protocol SearchManagerDelegate {
    
    func didFindHostWith(peerID: MCPeerID)
    func didLoseHostWith(peerID: MCPeerID)

}

class SearchManager: NSObject {
    
    var myPeerID: MCPeerID
    var hostsPeerID: [MCPeerID]
    var session: MCSession
    var browser: MCNearbyServiceBrowser
    var delegate: SearchManagerDelegate?
    
    override init() {
        self.myPeerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(Utils.getRandomID(length: 4))")
        self.hostsPeerID = [MCPeerID]()
        self.session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.browser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: "niu-niu-game")
        super.init()
        self.browser.delegate = self
    }
    
    // MARK: Browser's methods
    func startBrowsing() {
        self.browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        self.browser.stopBrowsingForPeers()
    }

    // MARK: Hosts' methods
    func getHosts() -> [MCPeerID] {
        return self.hostsPeerID
    }
        
    func getNumberOfHosts() -> Int {
        return self.hostsPeerID.count
    }
    
    func getIndexOf(host mcPeerID: MCPeerID) -> Int? {
        return self.hostsPeerID.firstIndex(of: mcPeerID)
    }
    
    func addHostWith(peerID: MCPeerID) {
        self.hostsPeerID.append(peerID)
    }
    
    func removeHostWith(index: Int) {
        self.hostsPeerID.remove(at: index)
    }
    
    func clearHosts() {
        self.hostsPeerID = [MCPeerID]()
    }

    // MARK: session's methods
    func disconnectSession() {
        self.session.disconnect()
    }
    
    func requestToJoin(where peerID: MCPeerID) {
        self.browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
    }
    
}

extension SearchManager: MCNearbyServiceBrowserDelegate {
    
    // A host is found
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.delegate?.didFindHostWith(peerID: peerID)
    }
    
    // A host is disappeared
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.didLoseHostWith(peerID: peerID)
    }
    
}
