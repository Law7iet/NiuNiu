//
//  GameVC.swift
//  NiuNiu
//
//  Created by Han Chu on 24/07/22.
//

import UIKit

class GameVC: UIViewController {

    // MARK: Properties
    var server: Server?
    var client: Client?
    var player: Player?
    var players: [Player]?
    
    @IBOutlet weak var showButton: UIButton!
    
    // MARK: Supporting functions
    func setupMenu() {
        let quitAction = UIAction(title: "Quit", image: UIImage(systemName: "rectangle.portrait.and.arrow.right")) { (action) in
            let message = "If you quit the game, the game will end. Are you sure to quit?"
//            let message = "If you quit the game, you won't be able to play until the game ends. Are you sure to quit?"
            let alert = UIAlertController(
                title: "Quit the game",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "No",
                style: .default)
            )
            alert.addAction(UIAlertAction(
                title: "Yes",
                style: .destructive,
                handler: { action in
                    // Notify and exit
//                    self.comms.sendMessageToServer(message: Message(.closeSession))
//                    self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
                }
            ))
            self.present(alert, animated: true)
        }

        let menu = UIMenu(title: "Menu", options: .displayInline, children: [quitAction])

        showButton.menu = menu
        showButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupMenu()
    }
    



}
