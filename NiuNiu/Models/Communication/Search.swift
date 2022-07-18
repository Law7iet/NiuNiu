//
//  SearchManager.swift
//  NiuNiu
//
//  Created by Han Chu on 10/07/22.
//

import MultipeerConnectivity

protocol SearchDelegate {
    
    func didFindHostWith(peerID: MCPeerID)
    func didLoseHostWith(peerID: MCPeerID)

}

class Search: NSObject {

    var session: MCSession
    var browser: MCNearbyServiceBrowser
    var delegate: SearchDelegate?
    
    init(peerID: MCPeerID) {
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "niu-niu-game")
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

    // MARK: session's methods
    func disconnectSession() {
        self.session.disconnect()
    }
    
    func requestToJoin(where peerID: MCPeerID) {
        self.browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
    }
    
}

extension Search: MCNearbyServiceBrowserDelegate {
    
    // A host is found
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.delegate?.didFindHostWith(peerID: peerID)
    }
    
    // A host is disappeared
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.didLoseHostWith(peerID: peerID)
    }
    
}
