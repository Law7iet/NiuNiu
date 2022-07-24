//
//  MainVC.swift
//  NiuNiu
//
//  Created by Han Chu on 06/06/22.
//

import UIKit
import MultipeerConnectivity

class MainVC: UIViewController {
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getRandomID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< 4).map{ _ in letters.randomElement()! })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let name = UIDevice.current.name + " #" + getRandomID()
        if let lobbyVC = segue.destination as? LobbyVC {
            lobbyVC.server = Server(peerID: MCPeerID(displayName: name))
            lobbyVC.client = Client(peerID: MCPeerID(displayName: name))
        } else if let searchVC = segue.destination as? SeacherVC {
            searchVC.client = Client(peerID: MCPeerID(displayName: name))
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
    
}

