//
//  SettingsVC.swift
//  NiuNiu
//
//  Created by Han Chu on 07/08/22.
//

import UIKit

class SettingsVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var pointsSlider: UISlider!
    @IBOutlet weak var playersSlider: UISlider!
    
    // MARK: Supporting functions
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self

        self.usernameTextField.text = Settings.username
        self.timerLabel.text = "Timer: \(Settings.timerLong)"
        self.timerSlider.setValue(Float(Settings.timerLong), animated: true)
        self.pointsLabel.text = "Points: \(Settings.points)"
        self.pointsSlider.setValue(Float(Settings.points), animated: true)
        self.playersLabel.text = "Number of players: \(Settings.numberOfPlayers)"
        self.playersSlider.setValue(Float(Settings.numberOfPlayers), animated: true)
    }
    
    // MARK: Actions
    @IBAction func changeTimerSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.timerLabel.text = "Timer: \(currentValue)"
    }
    
    @IBAction func changePointsSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.pointsLabel.text = "Points: \(currentValue)"
    }

    @IBAction func changePlayersSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.playersLabel.text = "Number of players: \(currentValue)"
    }
    
    @IBAction func clickSave(_ sender: Any) {
        // Username
        var username = self.usernameTextField.text!
        if username.isEmpty || username.trimmingCharacters(in: .whitespaces).isEmpty {
            username = UIDevice.current.name
        } else {
            username = username.trimmingCharacters(in: .whitespaces)
        }
        Settings.saveSettings(
            username: username,
            timer: Int(self.timerSlider.value),
            points: Int(self.pointsSlider.value),
            numberOfPlayers: Int(self.playersSlider.value)
        )
        // Turn back
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
