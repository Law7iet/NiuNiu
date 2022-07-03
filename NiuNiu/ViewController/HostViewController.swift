//
//  HostViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController, MCSessionDelegate {
    
    // MARK: Variables for multipeer connectivity
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var waitingPlayers = [String]()
    @IBOutlet weak var waitingPlayerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + Utils.getRandomID(length: 4)))
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        mcAdvertiserAssistant = MCAdvertiserAssistant(
            serviceType: "NiuNiuGame",
            discoveryInfo: nil,
            session: mcSession
        )
        mcAdvertiserAssistant.start()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func playGame(_ segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }

    func convertArrayToString() -> String {
        var text = ""
        for player in waitingPlayers {
            text = text + player + "\n"
        }
        return text
    }
    
    // MARK: Multipeer Connectivity Session's delegate implementation
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.waitingPlayers.append(peerID.displayName)
                let text = self.convertArrayToString()
                self.waitingPlayerLabel.text = text
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                if let index = self.waitingPlayers.firstIndex(of: peerID.displayName) {
                    self.waitingPlayers.remove(at: index)
                    self.waitingPlayerLabel.text = self.convertArrayToString()
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
