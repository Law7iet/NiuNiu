//
//  ClientGameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class ClientGameViewController: UIViewController {

    // MARK: Variables
    var clientManager: LobbyManager!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let msg = self.textField.text {
            let message = Message(type: .testMessage, text: msg, cards: nil)
            self.clientManager.sendMessageTo(receiver: self.clientManager.hostPeerID, message: message)
        }
    }
}

extension ClientGameViewController: LobbyManagerDelegate {
    
    // Not used
    func didConnectWith(peerID: MCPeerID) {}
    func didDisconnectWith(peerID: MCPeerID) {}
    
    func didReceiveMessageFrom(sender peerID: MCPeerID, messageData: Data) {
        if peerID == self.clientManager.hostPeerID {
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
    
    
}
