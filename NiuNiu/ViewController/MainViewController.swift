//
//  ViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/06/22.
//

import UIKit
import MultipeerConnectivity

protocol MainViewControllerDelegate: AnyObject {
    func didNotConnected(user: String)
    func didConnected(user: String)
}

func getRandomID(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0 ..< length).map{ _ in letters.randomElement()! })
}

class MainViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    weak var delegate: MainViewControllerDelegate?
    
    @IBAction func backToHome(_ segue: UIStoryboardSegue) {}
    
    @IBAction func hostGameAction(_ sender: Any) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(
            serviceType: "NiuNiuGame",
            discoveryInfo: nil,
            session: mcSession
        )
        mcAdvertiserAssistant.start()
    }
    
    @IBAction func joinGameAction(_ sender: Any) {
        let mcBrowser = MCBrowserViewController(
            serviceType: "NiuNiuGame",
            session: mcSession
        )
        mcBrowser.delegate = self
        self.present(mcBrowser, animated: true, completion: nil)
    }
    
    // MARK: Variables and functions for multipeer connectivity
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    func setupConnectivity() {
        peerID = MCPeerID(displayName: (UIDevice.current.name + " #" + getRandomID(length: 4)))
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConnectivity()
    }

    // MARK: Multipeer Connectivity Session's delegate implementation
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            delegate?.didConnected(user: peerID.displayName)
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            delegate?.didNotConnected(user: peerID.displayName)
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

