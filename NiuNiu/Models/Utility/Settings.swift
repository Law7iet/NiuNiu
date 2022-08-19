//
//  Settings.swift
//  NiuNiu
//
//  Created by Han Chu on 08/08/22.
//

import Foundation
import UIKit

class Settings {
    
    // MARK: Settings' data
    static var username: String { UserDefaults.standard.string(forKey: "username") ?? UIDevice.current.name }
    static var numberOfPlayers: Int { getInteger(forKey: "numberOfPlayers") ?? 5 }
    static var points: Int { getInteger(forKey: "points") ?? 50 }
    static var timerLong: Int { getInteger(forKey: "timer") ?? 20 }
    
    private static func getInteger(forKey key: String) -> Int? {
        let x = UserDefaults.standard.integer(forKey: key)
        if x == 0 {
            return nil
        } else {
            return x
        }
    }
    
    /// Update the data of the settings with the variables passed by parameters.
    /// - Parameters:
    ///   - username: the username of the player.
    ///   - timer: the timer of each game status.
    ///   - points: the initial points for alla players.
    ///   - numberOfPlayers: the number of players allowed in the lobby.
    static func saveSettings(username: String, timer: Int, points: Int, numberOfPlayers: Int) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(timer, forKey: "timer")
        UserDefaults.standard.set(points, forKey: "points")
        UserDefaults.standard.set(numberOfPlayers, forKey: "numberOfPlayers")
    }
    
}
