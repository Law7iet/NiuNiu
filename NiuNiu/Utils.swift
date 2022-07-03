//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 03/07/22.
//

class Utils {
    static func getRandomID(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map{ _ in letters.randomElement()! })
    }
}
