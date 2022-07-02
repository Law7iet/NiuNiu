//
//  JoinViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 01/07/22.
//

import UIKit
import MultipeerConnectivity

class JoinViewController: UIViewController, MainViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: Multipeer Connectivity Session's delegate implementation
    func didNotConnected(user: String) {
        print("MainViewControllerDelegate of JoinViewController - didNotConnected")
    }
    
    func didConnected(user: String) {
        print("MainViewControllerDelegate of JoinViewController - didConnected")
    }
    
}
