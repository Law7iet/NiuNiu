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
    
    // MARK: Supporting functions
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("OO")
        self.usernameTextField.delegate = self

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

}

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.text!)
        textField.resignFirstResponder()
        return true
    }
}
