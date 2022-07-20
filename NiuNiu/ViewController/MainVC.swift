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
    
    func getRandomID(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map{ _ in letters.randomElement()! })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let peerID = MCPeerID(displayName: "\(UIDevice.current.name) #\(self.getRandomID(length: 4))")
        if let serverLobbyVC = segue.destination as? ServerLobbyVC {
            let lobby = Lobby(user: peerID)
            serverLobbyVC.comms = Server(peerID: peerID)
            serverLobbyVC.lobby = lobby
        } else if let searchVC = segue.destination as? ClientSeacherVC {
            let lobby = Lobby(user: peerID)
            searchVC.comms = Client(peerID: peerID)
            searchVC.lobby = lobby
        }
    }
    
}

