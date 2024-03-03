//
//  Action.swift
//  poker-frontend
//
//  Created by Khoi Nguyen on 3/3/24.
//

import Foundation

struct Action {
    var playerNumber: Int
    var betSize: Int
    var actionType: ActionType
    var position: Position
    var isHero: Bool
    var street: Street
}

enum ActionType {
    case check
    case call
    case raise
    case fold
}

enum Position {
    case utg
    case utg1
    case utg2
    case lojack
    case hijack
    case cutoff
    case button
    case smallBlind
    case bigBlind
}

enum Street {
    case preflop, flop, turn, river
}


