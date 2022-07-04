//
//  JoinViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class JoinViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    // MARK: Variables for multipeer connectivity
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var hostList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + Utils.getRandomID(length: 4)))
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mcBrowser = MCBrowserViewController(
            serviceType: "niu-niu-game",
            session: mcSession
        )
        mcBrowser.delegate = self
        present(mcBrowser, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: Multipeer Connectivity Session's delegate implementation
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        print("Done")
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        print("Cancel")
        dismiss(animated: true, completion: nil)
    }
    
}
