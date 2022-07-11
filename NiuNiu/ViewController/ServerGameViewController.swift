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
    var serverManager: ServerManager!
    var receiver: MCPeerID!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    // MARK: Functions
    func setUserButton() {
        var childrenActions: [UIAction] = []
        for user in self.serverManager.playersPeerID {
            childrenActions.append(UIAction(title: user.displayName) { (action) in
                self.receiver = user
            })
        }
        
        // Setup the first/default value
//        childrenActions[0].state = .on
        self.receiver = self.serverManager.playersPeerID[0]
        
        
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
        self.serverManager.delegate = self
    }
    
    // MARK: Actions
    @IBAction func sendMessage(_ sender: Any) {
        if let msg = self.textField.text {
            let message = Message(type: .testMessage, text: msg, cards: nil)
            self.serverManager.sendMessageTo(receiver: self.receiver, message: message)
        }
    }
    
}

extension ServerGameViewController: ServerManagerDelegate {
    
    func didConnectWith(peerID: MCPeerID) {}
    func didDisconnectWith(peerID: MCPeerID) {}
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        let message = Message(data: messageData)
        switch message.type {
        case .testMessage:
            DispatchQueue.main.async {
                self.label.text = message.text
            }
        default:
            print("???")
        }
    }
    
    
}
