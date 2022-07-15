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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let serverVC = segue.destination as? HostViewController {
            serverVC.serverManager = ServerManager()
        } else if let searchVC = segue.destination as? SearchViewController {
            searchVC.searchManager = SearchManager()
        }
    }
    
}

