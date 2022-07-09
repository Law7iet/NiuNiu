//
//  MainViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 06/06/22.
//

import UIKit
import MultipeerConnectivity

class MainViewController: UIViewController {
        
    var myID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myID = Utils.getRandomID(length: 4)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let hostVC = segue.destination as? ServerViewController {
            hostVC.myID = self.myID
        } else if let searchVC = segue.destination as? SearchViewController {
            searchVC.myID = self.myID
        }
    }
    
}

