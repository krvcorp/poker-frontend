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
        "\(rank.rawValue) of \(suit.rawValue)"
    }

    /// Create a placeholder card
    /// - Parameters: None
    /// - Returns: CardModel
    /// - Throws: None
    /// - Complexity: O(1)
    /// - Note: This is a static function
    static func placeholder() -> CardModel {
        CardModel(suit: .placeholder, rank: .placeholder)
    }

    /// Check if the card is a placeholder
    /// - Parameters: None
    /// - Returns: Bool
    /// - Throws: None
    /// - Complexity: O(1)
    /// - Note: This is a computed property
    var isPlaceholder: Bool {
        suit == .placeholder && rank == .placeholder
    }


    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}
