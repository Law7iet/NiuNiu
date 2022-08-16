//
//  Settings.swift
//  NiuNiu
//
//  Created by Han Chu on 08/08/22.
//

import Foundation
import UIKit

class Settings {
    
    static var username: String { UserDefaults.standard.string(forKey: "username") ?? UIDevice.current.name }
    static var numberOfPlayers: Int { getInteger(forKey: "numberOfPlayers") ?? 5 }
    static var points: Int { getInteger(forKey: "points") ?? 50 }
    static var timerLong: Int { getInteger(forKey: "timer") ?? 30 }
    
    static let timerShort = 3
    static let timerOffset = 1
    
    // Time values
    static let timeStartBet =   timerShort + (1 * timerOffset) + (0 * timerLong)
    static let timeStopBet =    timerShort + (2 * timerOffset) + (1 * timerLong) - 1
    static let timeStartCheck = timerShort + (2 * timerOffset) + (1 * timerLong)
    static let timeStopCheck =  timerShort + (2 * timerOffset) + (2 * timerLong) - 1
    static let timeStartCards = timerShort + (3 * timerOffset) + (2 * timerLong)
    static let timeStopCards =  timerShort + (3 * timerOffset) + (3 * timerLong) - 1
    static let timeStartEnd =   timerShort + (4 * timerOffset) + (3 * timerLong)
    
    static func getInteger(forKey key: String) -> Int? {
        let x = UserDefaults.standard.integer(forKey: key)
        if x == 0 {
            return nil
        } else {
            return x
        }
    }
    
    static func saveSettings(username: String, timer: Int, points: Int, numberOfPlayers: Int) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(timer, forKey: "timer")
        UserDefaults.standard.set(points, forKey: "points")
        UserDefaults.standard.set(numberOfPlayers, forKey: "numberOfPlayers")
    }
    
}
