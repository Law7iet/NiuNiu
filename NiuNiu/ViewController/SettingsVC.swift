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
        
        let username = UserDefaults.standard.string(forKey: "username")
        let timer = UserDefaults.standard.integer(forKey: "timer")
        let points = UserDefaults.standard.integer(forKey: "points")
        let players = UserDefaults.standard.integer(forKey: "numberOfPlayers")
        
        if username != nil {
            self.usernameTextField.text = username
        } else {
            usernameTextField.text = UIDevice.current.name
        }
        
        if timer != 0 {
            self.timerLabel.text = "Timer: \(timer)"
            self.timerSlider.setValue(Float(timer), animated: true)
        } else {
            self.timerLabel.text = "Timer: 20"
            self.timerSlider.setValue(20.0, animated: true)
        }

        if points != 0 {
            self.pointsLabel.text = "Points: \(points)"
            self.pointsSlider.setValue(Float(points), animated: true)
        } else {
            self.pointsLabel.text = "Points: 50"
            self.pointsSlider.setValue(50.0, animated: true)
        }
        
        if players != 0 {
            self.playersLabel.text = "Number of players: \(players)"
            self.playersSlider.setValue(Float(players), animated: true)
        } else {
            self.playersLabel.text = "Number of players: 6"
            self.playersSlider.setValue(6.0, animated: true)
        }
        
    }
    
    // MARK: Actions
    @IBAction func changeTimerSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.timerLabel.text = "Timer: \(currentValue)"
        UserDefaults.standard.set(currentValue, forKey: "timer")
    }
    
    @IBAction func changePointsSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.pointsLabel.text = "Points: \(currentValue)"
        UserDefaults.standard.set(currentValue, forKey: "points")
    }

    @IBAction func changePlayersSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.playersLabel.text = "Number of players: \(currentValue)"
        UserDefaults.standard.set(currentValue, forKey: "numberOfPlayers")
    }
}

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UserDefaults.standard.set(textField.text!, forKey: "username")
        textField.resignFirstResponder()
        return true
    }
}