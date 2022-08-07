//
//  MainVC.swift
//  NiuNiu
//
//  Created by Han Chu on 06/06/22.
//

import UIKit
import MultipeerConnectivity

class MainVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var playBtn: UIButton!
    
    
    // MARK: Supporting functions
    func getRandomID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< 4).map{ _ in letters.randomElement()! })
    }
    
    func setupPlayBtn() {
        let hostBtn = UIAction(title: "Create a lobby", image: UIImage(systemName: "server.rack")) { (action) in
            self.performSegue(withIdentifier: "showLobbySegue", sender: nil)
        }
        let joinBtn = UIAction(title: "Find a lobby", image: UIImage(systemName: "magnifyingglass")) { (action) in
            self.performSegue(withIdentifier: "showSearcherSegue", sender: nil)
        }
        let menu = UIMenu(title: "Play", options: .displayInline, children: [hostBtn, joinBtn])
        self.playBtn.showsMenuAsPrimaryAction = true
        self.playBtn.menu = menu
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPlayBtn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let name = UIDevice.current.name + " #" + self.getRandomID()
        if let lobbyVC = segue.destination as? LobbyVC {
            lobbyVC.server = Server(peerID: MCPeerID(displayName: name))
            lobbyVC.client = Client(peerID: MCPeerID(displayName: name))
        } else if let searchVC = segue.destination as? SeacherVC {
            searchVC.client = Client(peerID: MCPeerID(displayName: name))
        }
    }
    
    @IBAction func unwindToMainVC(segue: UIStoryboardSegue) {}
    
}

