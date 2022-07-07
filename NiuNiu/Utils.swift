//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 03/07/22.
//

import MultipeerConnectivity

class Utils {
    static func getRandomID(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map{ _ in letters.randomElement()! })
    }
    
    static func convertMCPeerIDListToString(list: [MCPeerID]) -> [String] {
        var peerList = [String]()
        for el in list {
            peerList.append(el.displayName)
        }
        return peerList
    }
}
