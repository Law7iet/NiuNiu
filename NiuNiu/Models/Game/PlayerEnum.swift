//
//  PlayerEnum.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

enum PlayerEnum: Codable {

    // The player is out
    case fold
    // The player bet all his points
    case allIn
    // The player choose his cards
    case cards
    
    case none
}
