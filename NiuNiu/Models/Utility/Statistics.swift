//
//  Statistics.swift
//  NiuNiu
//
//  Created by Han Chu on 15/08/22.
//

import Foundation

class Statistics {
 
    // MARK: Data of statics
    static var gamesPlayed: Int { UserDefaults.standard.integer(forKey: "gamesPlayed") }
    static var gamesWon: Int { UserDefaults.standard.integer(forKey: "gamesWon") }
    static var gamesWinRate: Float { self.gamesPlayed == 0 ? 0 : round(Float(self.gamesWon) / Float(self.gamesPlayed) * 100) }
    static var roundsPlayed: Int { UserDefaults.standard.integer(forKey: "roundsPlayed") }
    static var roundsWon: Int { UserDefaults.standard.integer(forKey: "roundsWon") }
    static var roundsWinRate: Float { self.roundsPlayed == 0 ? 0 : round(Float(self.roundsWon) / Float(self.roundsPlayed) * 100) }
    static var pointsGained: Int { UserDefaults.standard.integer(forKey: "pointsGained") }
    
    
    /// Reset all the statistics' data.
    static func reset() {
        UserDefaults.standard.set(0, forKey: "gamesPlayed")
        UserDefaults.standard.set(0, forKey: "gamesWon")
        UserDefaults.standard.set(0, forKey: "roundsPlayed")
        UserDefaults.standard.set(0, forKey: "roundsWon")
        UserDefaults.standard.set(0, forKey: "pointsGained")
    }
    
    /// Increase the `gamesPlayed` by 1.
    static func increaseGamesPlayed() {
        UserDefaults.standard.set(self.gamesPlayed + 1, forKey: "gamesPlayed")
    }
    
    /// Increase the `gamesWon` by 1.
    static func increaseGamesWon() {
        UserDefaults.standard.set(self.gamesWon + 1, forKey: "gamesWon")
    }
    
    /// Increase the `roundsPlayed` by 1.
    static func increaseRoundsPlayed() {
        UserDefaults.standard.set(self.roundsPlayed + 1, forKey: "roundsPlayed")
    }
    
    /// Increase the `roundsWon` by 1.
    static func increaseRoundsWon() {
        UserDefaults.standard.set(self.roundsWon + 1, forKey: "roundsWon")
    }
    
    /// Increase the `pointsGained` by 1.
    static func addPointsGained(points: Int) {
        UserDefaults.standard.set(self.pointsGained + points, forKey: "pointsGained")
    }
    
}
