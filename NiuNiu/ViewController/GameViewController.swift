//
//  GameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    // MARK: Variables
    var receiver: MCPeerID!
    var users: PeerList!
    var session: MCSession!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Functions
    func setUserButton() {
        var childrenActions: [UIAction] = []
        for user in users.list {
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
        let message = self.textField.text
        if message == nil {
            return
        }
        let data = Data(message!.utf8)
        do {
            try self.session.send(
                data,
                toPeers: [self.receiver],
                with: .reliable
            )
        } catch {
            print("try self.session.send error")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
