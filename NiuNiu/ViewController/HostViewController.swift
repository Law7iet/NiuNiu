//
//  HostViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController, MCSessionDelegate {

    var waitingPlayers = [String]()
    @IBOutlet weak var waitingPlayerLabel: UILabel!
    
    func convertWaitingListToString() -> String {
        var x = ""
        for player in waitingPlayers {
            x = x + player + "\n"
        }
        return x
    }
    
    // MARK: Variables and functions for multipeer connectivity
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    func setupConnectivity() {
//        peerID = MCPeerID(displayName: (UIDevice.current.name + " " + (UIDevice.current.identifierForVendor?.uuidString ?? "")))
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }

    @IBAction func playGame(_ segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConnectivity()
        
        mcAdvertiserAssistant = MCAdvertiserAssistant(
            serviceType: "NiuNiuGame",
            discoveryInfo: nil,
            session: mcSession
        )
        mcAdvertiserAssistant.start()
    }
    
    // MARK: Multipeer Connectivity Session's delegate implementation
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.waitingPlayers.append(peerID.displayName)
                let text = self.convertWaitingListToString()
                self.waitingPlayerLabel.text = text
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                if let index = self.waitingPlayers.firstIndex(of: peerID.displayName) {
                    self.waitingPlayers.remove(at: index)
                    self.waitingPlayerLabel.text = self.convertWaitingListToString()
                }
            }
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

}
