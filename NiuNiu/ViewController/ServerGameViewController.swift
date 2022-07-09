//
//  ServerGameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ServerGameViewController: UIViewController {
    
    // MARK: Variables
    var receiver: MCPeerID!
    var users: [MCPeerID]!
    var myPeerID: MCPeerID!
    var mcSession: MCSession!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Functions
    func setUserButton() {
        var childrenActions: [UIAction] = []
        for user in self.users {
            childrenActions.append(UIAction(title: user.displayName) { (action) in
                self.receiver = user
            })
        }
        
        userButton.menu = UIMenu(
            title: "Choose the receiver",
            image: nil,
            identifier: .application,
            options: [],
            children: childrenActions
        )
        userButton.showsMenuAsPrimaryAction = true
        userButton.changesSelectionAsPrimaryAction = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserButton()
    }
    
    // MARK: Actions
    @IBAction func sendMessage(_ sender: Any) {
        if let msg = self.textField.text {
            let message = Message(type: .testMessage, text: msg, cards: nil)
            if let data = message.convertToData() {
                do {
                    try self.mcSession.send(
                        data,
                        toPeers: [self.receiver],
                        with: .reliable
                    )
                } catch {
                    print("mcSession.send error")
                }
            }
        }
    }
    
}
