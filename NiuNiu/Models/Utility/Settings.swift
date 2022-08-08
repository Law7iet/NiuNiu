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
    static var numberOfPlayers: Int { getInteger(forKey: "numberOfPlayers") ?? 6 }
    static var points: Int { getInteger(forKey: "points") ?? 50 }
    
    static var timerLong: Int { getInteger(forKey: "timer") ?? 30 }
    static let timerShort = 2
    static let pendingTimer = 2.5
    static let timerOffset = 1
    
    static func getInteger(forKey key: String) -> Int? {
        let x = UserDefaults.standard.integer(forKey: key)
        if x == 0 {
            return nil
        } else {
            return x
        }
    }
    
}
