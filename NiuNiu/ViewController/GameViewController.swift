//
//  GameViewController.swift
//  NiuNiu
//
//  Created by Han Chu on 05/07/22.
//

import UIKit

class GameViewController: UIViewController {
    
    var receiver = ""
    var users: PeerList!
    
    @IBOutlet weak var userButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserButton()
    }
    
    func setUserButton() {
        var childrenActions: [UIAction] = []
        for user in users.list {
            childrenActions.append(UIAction(title: user.displayName) { (action) in
                self.receiver = user.displayName
            })
        }
        
        userButton.menu = UIMenu(
            title: "Choose the receiver",
            image: nil,
            identifier: .application,
            options: [],
            children: childrenActions
        )
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
