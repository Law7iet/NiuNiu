//
//  StatsVC.swift
//  NiuNiu
//
//  Created by Han Chu on 15/08/22.
//

import UIKit

class StatsVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var gamesNumLabel: UILabel!
    @IBOutlet weak var gamesWonLabel: UILabel!
    @IBOutlet weak var gamesWrLabel: UILabel!
    @IBOutlet weak var roundsNumLabel: UILabel!
    @IBOutlet weak var roundsWonLabel: UILabel!
    @IBOutlet weak var roundsWrLabel: UILabel!
    @IBOutlet weak var pointsGainedLabel: UILabel!
    
    // MARK: Supporting functions
    func setupUI() {
        self.gamesNumLabel.text = "Games played: \(Statistics.gamesPlayed)"
        self.gamesWonLabel.text = "Games won: \(Statistics.gamesWon)"
        self.gamesWrLabel.text = "Games win rate: \(Statistics.gamesWinRate)%"
        self.roundsNumLabel.text = "Rounds played: \(Statistics.roundsPlayed)"
        self.roundsWonLabel.text = "Rounds won: \(Statistics.roundsWon)"
        self.roundsWrLabel.text = "Rounds win rate: \(Statistics.roundsWinRate)%"
        self.pointsGainedLabel.text = "Points gained: \(Statistics.pointsGained)"
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    // MARK: Actions
    @IBAction func clickReset(_ sender: Any) {
        let alert = UIAlertController(
            title: "Delete data",
            message: "Do you want to delete all the data?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { (action: UIAlertAction) in
                Statistics.reset()
                self.setupUI()
            }
        ))
        alert.addAction(UIAlertAction(
            title: "No",
            style: .cancel
        ))
        self.present(alert, animated: true)
    }
    
}
