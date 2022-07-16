//
//  ServerGameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ServerGameViewController: UIViewController {
    
    // MARK: Properties
    var dealer: Dealer!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var playersLabel: [UILabel]!
    @IBOutlet var cardsButton: [UIButton]!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidSlider: UISlider!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dealer.serverManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.dealer.playGame()
    }
    
    // MARK: Actions
    @IBAction func bet(_ sender: Any) {
    
    }
    
    @IBAction func clickCard(_ sender: Any) {
        
    }
}


