//
//  ContentViewModel.swift
//  Poker Calculator
//
//  Created by Khoi Nguyen on 4/18/23.
//

import Foundation

enum Hand {
    case none
    case player1
    case player2
    case table

    var isNotNone: Bool {
        get {
            self != .none
        }
        set {
            if !newValue {
                self = .none
            }
        }
    }
}

class ContentViewModel : ObservableObject {
    @Published var selectedHand: Hand = .none
    
    @Published var cards = [CardModel]()
    @Published var player1Cards = [CardModel]()
    @Published var player2Cards = [CardModel]()
    @Published var tableCards = [CardModel]()
    
    @Published var player1Odds: Double = 0.0
    @Published var player2Odds: Double = 0.0
    @Published var tieOdds: Double = 0.0


    init() {
        cards = Suit.allCases.filter { $0 != .placeholder }.flatMap { suit in
            Rank.allCases.filter { $0 != .placeholder }.map { rank in
                CardModel(suit: suit, rank: rank)
            }
        }

        // Preset the player1 to have a royal flush and player2 to have a straight flush
        self.addCard(card: CardModel(suit: .diamonds, rank: .ace), hand: .player1)
        self.addCard(card: CardModel(suit: .spades, rank: .seven), hand: .player1)
        
        self.addCard(card: CardModel(suit: .hearts, rank: .six), hand: .table)
        self.addCard(card: CardModel(suit: .diamonds, rank: .three), hand: .table)
        self.addCard(card: CardModel(suit: .hearts, rank: .three), hand: .table)
        self.addCard(card: CardModel(suit: .hearts, rank: .two), hand: .table)
        self.addCard(card: CardModel(suit: .spades, rank: .two), hand: .table)

        self.addCard(card: CardModel(suit: .hearts, rank: .eight), hand: .player2)
        self.addCard(card: CardModel(suit: .spades, rank: .eight), hand: .player2)
    }



    /// Add a card to a hand
    /// - Parameters:
    /// - card: The card to add
    /// - hand: The hand to add
    /// - Returns: Void
    /// - Throws: None
    /// - Complexity: O(n)
    func addCard(card: CardModel) {
        switch selectedHand {
        case .none:
            print("None")
        case .player1:
            player1Cards.append(card)
        case .player2:
            player2Cards.append(card)
        case .table:
            tableCards.append(card)
        }

        cards.removeAll { $0 == card }
    }

    func addCard(card: CardModel, hand: Hand) {
        switch hand {
        case .none:
            print("None")
        case .player1:
            player1Cards.append(card)
        case .player2:
            player2Cards.append(card)
        case .table:
            tableCards.append(card)
        }

        cards.removeAll { $0 == card }
    }

    /// Remove a card from a hand
    /// - Parameters:
    /// - card: The card to remove
    /// - hand: The hand to remove the card from
    /// - Returns: Void
    /// - Throws: None
    /// - Complexity: O(n)
    func removeCard(card: CardModel, hand: Hand) {
        switch hand {
        case .none:
            print("None")
        case .player1:
            player1Cards.removeAll { $0 == card }
        case .player2:
            player2Cards.removeAll { $0 == card }
        case .table:
            tableCards.removeAll { $0 == card }
        }

        cards.append(card)
    }

    /// Calculate the probability of winning via simulation
    /// - Parameters:
    /// - player1Cards: The player 1 cards
    /// - player2Cards: The player 2 cards
    /// - tableCards: The table cards
    /// - Returns: Void
    /// - Throws: None
    /// - Complexity: O(n)
    func calculateWinningProbability() {
        var player1Wins: Int = 0
        var player2Wins: Int = 0
        var ties: Int = 0
        
        for i: Int in 1...2 {
            // create a local copy of the table
            var table = self.tableCards
            var cards = self.cards
            
            // populate the table with 5 cards randomly chosen from the local cards
            while table.count < 5 {
                let randomIndex = Int.random(in: 0..<cards.count)
                table.append(cards[randomIndex])
                cards.remove(at: randomIndex)
            }

            switch determineWinner(player1Cards: self.player1Cards, player2Cards: self.player2Cards, tableCards: table) {
            case .player1:
                player1Wins += 1
            case .player2:
                player2Wins += 1
            case .none:
                ties += 1
            default:
                break
            }

            // Print Progress
            if i % 100 == 0 {
                print("Progress: \(i % 100)")
            }
            
            self.player1Odds = Double(player1Wins) / Double(i) * 100
            self.player2Odds = Double(player2Wins) / Double(i) * 100
            self.tieOdds = Double(ties) / Double(i) * 100
        }
    }

    /// Helper function to determine which player won the hand
    /// - Parameters:
    /// - player1Cards: The player 1 cards
    /// - player2Cards: The player 2 cards
    /// - tableCards: The table cards
    /// - Returns: Void
    /// - Throws: None
    /// - Complexity: O(n)
    func determineWinner(player1Cards: [CardModel], player2Cards: [CardModel], tableCards: [CardModel]) -> Hand {
        var player1FullHand = player1Cards + tableCards
        var player2FullHand = player2Cards + tableCards
        
        // Sort player 1's full hand by descending rank and ascending suit
        player1FullHand.sort { (card1, card2) -> Bool in
            if card1.rank == card2.rank {
                return card1.suit.rawValue < card2.suit.rawValue
            } else {
                return card1.rank.rank > card2.rank.rank
            }
        }
        
        // Sort player 2's full hand by descending rank and ascending suit
        player2FullHand.sort { (card1, card2) -> Bool in
            if card1.rank == card2.rank {
                return card1.suit.rawValue < card2.suit.rawValue
            } else {
                return card1.rank.rank > card2.rank.rank
            }
        }

        var player1RoyalFlush: Bool = false
        var player2RoyalFlush: Bool = false
        var player1StraightFlush: Bool = false
        var player2StraightFlush: Bool = false
        var player1FourOfAKind: Bool = false
        var player2FourOfAKind: Bool = false
        var player1FullHouse: Bool = false
        var player2FullHouse: Bool = false
        var player1Flush: Bool = false
        var player2Flush: Bool = false
        var player1Straight: Bool = false
        var player2Straight: Bool = false
        var player1ThreeOfAKind: Bool = false
        var player2ThreeOfAKind: Bool = false
        var player1TwoPair: Bool = false
        var player2TwoPair: Bool = false
        var player1Pair: Bool = false
        var player2Pair: Bool = false
        
        var player1FlushSuit : Suit = .placeholder
        var player2FlushSuit : Suit = .placeholder
        for suit in Suit.allCases.filter({ $0 != .placeholder }) {
            var player1SuitCount = 0
            var player2SuitCount = 0
            for card in player1FullHand {
                if card.suit == suit {
                    player1SuitCount += 1
                }
            }
            for card in player2FullHand {
                if card.suit == suit {
                    player2SuitCount += 1
                }
            }
            if player1SuitCount == 5 {
                player1Flush = true
                player1FlushSuit = suit
            }
            if player2SuitCount == 5 {
                player2Flush = true
                player2FlushSuit = suit
            }
        }
        
        var player1StraightRank = 0
        for i in 0..<player1FullHand.count - 4 {
            if player1FullHand[i].rank.rank == player1FullHand[i + 1].rank.rank + 1 && player1FullHand[i + 1].rank.rank + 1 == player1FullHand[i + 2].rank.rank + 2 && player1FullHand[i + 2].rank.rank + 2 == player1FullHand[i + 3].rank.rank + 3 && player1FullHand[i + 3].rank.rank + 3 == player1FullHand[i + 4].rank.rank + 4 {
                player1Straight = true
                player1StraightRank = player1FullHand[i].rank.rank
                // check if straight flush
                if player1FullHand[i].suit == player1FullHand[i + 1].suit && player1FullHand[i + 1].suit == player1FullHand[i + 2].suit && player1FullHand[i + 2].suit == player1FullHand[i + 3].suit && player1FullHand[i + 3].suit == player1FullHand[i + 4].suit {
                    player1StraightFlush = true
                    if player1StraightRank == 14 {
                        player1RoyalFlush = true
                    }
                }
            }
        }
        var player2StraightRank = 0
        for i in 0..<player2FullHand.count - 4 {
            if player2FullHand[i].rank.rank == player2FullHand[i + 1].rank.rank + 1 && player2FullHand[i + 1].rank.rank + 1 == player2FullHand[i + 2].rank.rank + 2 && player2FullHand[i + 2].rank.rank + 2 == player2FullHand[i + 3].rank.rank + 3 && player2FullHand[i + 3].rank.rank + 3 == player2FullHand[i + 4].rank.rank + 4 {
                player2Straight = true
                player2StraightRank = player2FullHand[i].rank.rank
                // check if straight flush
                if player2FullHand[i].suit == player2FullHand[i + 1].suit && player2FullHand[i + 1].suit == player2FullHand[i + 2].suit && player2FullHand[i + 2].suit == player2FullHand[i + 3].suit && player2FullHand[i + 3].suit == player2FullHand[i + 4].suit {
                    player2StraightFlush = true
                    if player2StraightRank == 14 {
                        player2RoyalFlush = true
                    }
                }
            }
        }

        // win condition for royal flush
        if player1RoyalFlush && player2RoyalFlush {
            return .none
        } else if player1RoyalFlush {
            return .player1
        } else if player2RoyalFlush {
            return .player2
        }

        // win condition for straight flush
        if player1StraightFlush && player2StraightFlush {
            if player1StraightRank > player2StraightRank {
                return .player1
            } else if player1StraightRank < player2StraightRank {
                return .player2
            } else {
                return .none
            }
        } else if player1StraightFlush {
            return .player1
        } else if player2StraightFlush {
            return .player2
        }

        // 4 of a Kind Check
        var player1FourOfAKindRank: Int = 0
        var player2FourOfAKindRank: Int = 0
        for i in 0..<player1FullHand.count - 3 {
            if player1FullHand[i].rank == player1FullHand[i + 1].rank && player1FullHand[i + 1].rank == player1FullHand[i + 2].rank && player1FullHand[i + 2].rank == player1FullHand[i + 3].rank {
                player1FourOfAKind = true
                player1FourOfAKindRank = player1FullHand[i].rank.rank
            }
            if player2FullHand[i].rank == player2FullHand[i + 1].rank && player2FullHand[i + 1].rank == player2FullHand[i + 2].rank && player2FullHand[i + 2].rank == player2FullHand[i + 3].rank {
                player2FourOfAKind = true
                player2FourOfAKindRank = player2FullHand[i].rank.rank
            }
        }
        
        if player1FourOfAKind && player2FourOfAKind {
            if player1FourOfAKindRank > player2FourOfAKindRank {
                return .player1
            } else if player1FourOfAKindRank < player2FourOfAKindRank {
                return .player2
            } else {
                // find kicker
                var player1Kicker: Int = 0
                var player2Kicker: Int = 0
                for card in player1FullHand {
                    if card.rank.rank != player1FourOfAKindRank && card.rank.rank > player1Kicker {
                        player1Kicker = card.rank.rank
                    }
                }
                for card in player2FullHand {
                    if card.rank.rank != player2FourOfAKindRank && card.rank.rank > player2Kicker {
                        player2Kicker = card.rank.rank
                    }
                }
                if player1Kicker > player2Kicker {
                    return .player1
                } else if player1Kicker < player2Kicker {
                    return .player2
                } else {
                    return .none
                }
            }
        } else if player1FourOfAKind {
            return .player1
        } else if player2FourOfAKind {
            return .player2
        }
        
        // 3 of a Kind Check
        var player1ThreeOfAKindRank = 0
        var player2ThreeOfAKindRank = 0
        for i in 0..<player1FullHand.count - 2 {
            if player1FullHand[i].rank == player1FullHand[i + 1].rank && player1FullHand[i + 1].rank == player1FullHand[i + 2].rank {
                player1ThreeOfAKind = true
                player1ThreeOfAKindRank = player1FullHand[i].rank.rank
            }
            if player2FullHand[i].rank == player2FullHand[i + 1].rank && player2FullHand[i + 1].rank == player2FullHand[i + 2].rank {
                player2ThreeOfAKind = true
                player2ThreeOfAKindRank = player2FullHand[i].rank.rank
            }
        }
        var player1FullHouseRank = 0
        var player2FullHouseRank = 0
        if player1ThreeOfAKind {
            // check if there are 2 cards of the same rank other than player1ThreeOfAKindRank
            player1FullHouse = false
            for i in 0..<player1FullHand.count - 1 {
                if player1FullHand[i].rank.rank == player1FullHand[i + 1].rank.rank && player1FullHand[i].rank.rank != player1ThreeOfAKindRank {
                    player1FullHouse = true
                    player1FullHouseRank = player1FullHand[i].rank.rank
                }
            }
        }
        if player2ThreeOfAKind {
            // check if there are 2 cards of the same rank other than player2ThreeOfAKindRank
            player2FullHouse = false
            for i in 0..<player2FullHand.count - 1 {
                if player2FullHand[i].rank.rank == player2FullHand[i + 1].rank.rank && player2FullHand[i].rank.rank != player2ThreeOfAKindRank {
                    player2FullHouse = true
                    player2FullHouseRank = player2FullHand[i].rank.rank
                }
            }
        }
        
        if player1FullHouse && player2FullHouse {
            if player1ThreeOfAKindRank > player2ThreeOfAKindRank {
                return .player1
            } else if player1ThreeOfAKindRank < player2ThreeOfAKindRank {
                return .player2
            } else {
                if player1FullHouseRank > player2FullHouseRank {
                    return .player1
                } else if player1FullHouseRank < player2FullHouseRank {
                    return .player2
                } else {
                    return .none
                }
            }
        } else if player1FullHouse {
            return .player1
        } else if player2FullHouse {
            return .player2
        }
        
        // win condition for flush
        if player1Flush && player2Flush {
            // compare highest card of flush suit
            var player1FlushRank = 0
            var player2FlushRank = 0
            for card in player1FullHand {
                if card.suit == player1FlushSuit && card.rank.rank > player1FlushRank {
                    player1FlushRank = card.rank.rank
                }
            }
            for card in player2FullHand {
                if card.suit == player2FlushSuit && card.rank.rank > player2FlushRank {
                    player2FlushRank = card.rank.rank
                }
            }
            if player1FlushRank > player2FlushRank {
                return .player1
            } else if player1FlushRank < player2FlushRank {
                return .player2
            } else {
                return .none
            }
        } else if player1Flush {
            return .player1
        } else if player2Flush {
            return .player2
        }

        // win condition for straight
        if player1Straight && player2Straight {
            if player1StraightRank > player2StraightRank {
                return .player1
            } else if player1StraightRank < player2StraightRank {
                return .player2
            } else {
                return .none
            }
        } else if player1Straight {
            return .player1
        } else if player2Straight {
            return .player2
        }

        // win condition for three of a kind
        if player1ThreeOfAKind && player2ThreeOfAKind {
            if player1ThreeOfAKindRank > player2ThreeOfAKindRank {
                return .player1
            } else if player1ThreeOfAKindRank < player2ThreeOfAKindRank {
                return .player2
            } else {
                // check for kicker
                var player1Kicker = 0
                var player2Kicker = 0
                for card in player1FullHand {
                    if card.rank.rank != player1ThreeOfAKindRank && card.rank.rank > player1Kicker {
                        player1Kicker = card.rank.rank
                    }
                }
                for card in player2FullHand {
                    if card.rank.rank != player2ThreeOfAKindRank && card.rank.rank > player2Kicker {
                        player2Kicker = card.rank.rank
                    }
                }
                if player1Kicker > player2Kicker {
                    return .player1
                } else if player1Kicker < player2Kicker {
                    return .player2
                } else {
                    return .none
                }
            }
        } else if player1ThreeOfAKind {
            return .player1
        } else if player2ThreeOfAKind {
            return .player2
        }

        // check if there is a pair
        var player1PairRank = 0
        var player2PairRank = 0
        for i in 0..<player1FullHand.count - 1 {
            if player1FullHand[i].rank == player1FullHand[i + 1].rank {
                player1Pair = true
                player1PairRank = player1FullHand[i].rank.rank
            }
            if player2FullHand[i].rank == player2FullHand[i + 1].rank {
                player2Pair = true
                player2PairRank = player2FullHand[i].rank.rank
            }
        }
        
        var player1TwoPairRank = 0
        if player1Pair {
            // check if there are is another pair with different rank
            player1TwoPair = false
            for i in 0..<player1FullHand.count - 1 {
                if player1FullHand[i].rank.rank == player1FullHand[i + 1].rank.rank && player1FullHand[i].rank.rank != player1PairRank {
                    player1TwoPair = true
                    player1TwoPairRank = player1FullHand[i].rank.rank
                }
            }
        }

        var player2TwoPairRank = 0
        if player2Pair {
            // check if there are is another pair with different rank
            player2TwoPair = false
            for i in 0..<player2FullHand.count - 1 {
                if player2FullHand[i].rank.rank == player2FullHand[i + 1].rank.rank && player2FullHand[i].rank.rank != player2PairRank {
                    player2TwoPair = true
                    player2TwoPairRank = player2FullHand[i].rank.rank
                }
            }
        }
        
        // print player1TwoPair, player1Pair, player1PairRank, player1TwoPairRank
        // print player2TwoPair, player2Pair, player2PairRank, player2TwoPairRank
        print(player1TwoPair, player1Pair, player1PairRank, player1TwoPairRank)
        print(player2TwoPair, player2Pair, player2PairRank, player2TwoPairRank)
        print(player1FullHand)
        print(player2FullHand)

        if player1TwoPair && player2TwoPair {
            if player1PairRank > player2PairRank {
                return .player1
            } else if player1PairRank < player2PairRank {
                return .player2
            } else {
                if player1TwoPairRank > player2TwoPairRank {
                    return .player1
                } else if player1TwoPairRank < player2TwoPairRank {
                    return .player2
                } else {
                    // check for kicker
                    var player1Kicker = 0
                    var player2Kicker = 0
                    for card in player1FullHand {
                        if card.rank.rank != player1TwoPairRank && card.rank.rank != player1PairRank && card.rank.rank > player1Kicker {
                            player1Kicker = card.rank.rank
                        }
                    }
                    for card in player2FullHand {
                        if card.rank.rank != player2TwoPairRank && card.rank.rank != player2PairRank && card.rank.rank > player2Kicker {
                            player2Kicker = card.rank.rank
                        }
                    }
                    if player1Kicker > player2Kicker {
                        return .player1
                    } else if player1Kicker < player2Kicker {
                        return .player2
                    } else {
                        return .none
                    }
                }
            }
        } else if player1TwoPair {
            return .player1
        } else if player2TwoPair {
            return .player2
        }
        
        if player1Pair && player2Pair {
            if player1PairRank > player2PairRank {
                return .player1
            } else if player1PairRank < player2PairRank {
                return .player2
            } else {
                // check for kicker
                var player1Kicker = 0
                var player2Kicker = 0
                for card in player1FullHand {
                    if card.rank.rank != player1PairRank && card.rank.rank > player1Kicker {
                        player1Kicker = card.rank.rank
                    }
                }
                for card in player2FullHand {
                    if card.rank.rank != player2PairRank && card.rank.rank > player2Kicker {
                        player2Kicker = card.rank.rank
                    }
                }
                if player1Kicker > player2Kicker {
                    return .player1
                } else if player1Kicker < player2Kicker {
                    return .player2
                } else {
                    return .none
                }
            }
        } else if player1Pair {
            return .player1
        } else if player2Pair {
            return .player2
        }
        
        // check first card of each hand and compare
        if player1FullHand[0].rank.rank > player2FullHand[0].rank.rank {
            return .player1
        } else if player1FullHand[0].rank.rank < player2FullHand[0].rank.rank {
            return .player2
        } else {
            return .none
        }
        
    }

}
