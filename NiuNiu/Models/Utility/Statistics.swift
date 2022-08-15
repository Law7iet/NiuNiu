//
//  Statistics.swift
//  NiuNiu
//
//  Created by Han Chu on 15/08/22.
//

import Foundation

class Statistics {
 
    static var gamesPlayed: Int {
        return UserDefaults.standard.integer(forKey: "gamesPlayed")
    }
    static var gamesWon: Int {
        return UserDefaults.standard.integer(forKey: "gamesWon")
    }
    static var gamesWinRate: Float {
        if self.gamesPlayed == 0 {
            return 0
        } else {
            return round(Float(self.gamesWon) / Float(self.gamesPlayed) * 100)
        }
    }
    static var roundsPlayed: Int {
        return UserDefaults.standard.integer(forKey: "roundsPlayed")
    }
    static var roundsWon: Int {
        return UserDefaults.standard.integer(forKey: "roundsWon")
    }
    static var roundsWinRate: Float {
        if self.roundsPlayed == 0 {
            return 0
        } else {
            return round(Float(self.roundsWon) / Float(self.roundsPlayed) * 100)
        }
    }
    static var pointsGained: Int {
        return UserDefaults.standard.integer(forKey: "pointsGained")
    }
    
    static func reset() {
        UserDefaults.standard.set(0, forKey: "gamesPlayed")
        UserDefaults.standard.set(0, forKey: "gamesWon")
        UserDefaults.standard.set(0, forKey: "roundsPlayed")
        UserDefaults.standard.set(0, forKey: "roundsWon")
        UserDefaults.standard.set(0, forKey: "pointsGained")
    }
    
    static func increaseGamesPlayed() {
        UserDefaults.standard.set(self.gamesPlayed + 1, forKey: "gamesPlayed")
    }
    
    static func increaseGamesWon() {
        UserDefaults.standard.set(self.gamesWon + 1, forKey: "gamesWon")
    }
    
    static func increaseRoundsPlayed() {
        UserDefaults.standard.set(self.roundsPlayed + 1, forKey: "roundsPlayed")
    }
    
    static func increaseRoundsWon() {
        UserDefaults.standard.set(self.roundsWon + 1, forKey: "roundsWon")
    }
    
    static func addPointsGained(points: Int) {
        UserDefaults.standard.set(self.pointsGained + points, forKey: "pointsGained")
    }
    
}
