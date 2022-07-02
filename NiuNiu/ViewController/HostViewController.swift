//
//  HostViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 30/06/22.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController, MainViewControllerDelegate {
    
    var waitingPlayers = [String]()
    @IBOutlet weak var waitingPlayerLabel: UILabel!
    
    func convertWaitingListToString() -> String {
        var x = ""
        for player in waitingPlayers {
            x = x + player + "\n"
        }
        return x
    }

    @IBAction func playGame(_ segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = MainViewController()
        vc.delegate = self
    }
    
    // MARK: MainViewControllerDelegate implementation
    func didNotConnected(user: String) {
        if let index = self.waitingPlayers.firstIndex(of: user) {
            self.waitingPlayers.remove(at: index)
            self.waitingPlayerLabel.text = self.convertWaitingListToString()
        }
    }
    
    func didConnected(user: String) {
        self.waitingPlayers.append(user)
        let text = self.convertWaitingListToString()
        self.waitingPlayerLabel.text = text
    }
    
}
