//
//  MainViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/06/22.
//

import UIKit
import MultipeerConnectivity

class MainViewController: UIViewController {
    
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
        if let hostVC = segue.destination as? HostViewController {
            let lobby = Lobby(himself: peerID, host: peerID)
            hostVC.hostManager = Server(peerID: peerID)
            hostVC.gameLobby = lobby
        } else if let searchVC = segue.destination as? SeacherViewController {
            let lobby = Lobby(himself: peerID)
            searchVC.searchManager = Search(peerID: peerID)
            searchVC.searchLobby = lobby
        }
    }
    
}

