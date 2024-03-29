//
//  CardModel.swift
//  Poker Calculator
//
//  Created by Khoi Nguyen on 4/18/23.
//

import Foundation

struct CardModel: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Rank

    var description: String {
        "\(rank.rawValue)\(suit.rawValue)"
    }

    static func placeholder() -> CardModel {
        CardModel(suit: .placeholder, rank: .placeholder)
    }

    var isPlaceholder: Bool {
        suit == .placeholder && rank == .placeholder
    }


    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}
