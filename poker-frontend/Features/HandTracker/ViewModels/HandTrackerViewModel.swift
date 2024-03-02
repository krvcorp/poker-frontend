//
//  HandTrackerViewModel.swift
//  poker-frontend
//
//  Created by Khoi Nguyen on 3/1/24.
//

import Foundation

struct Action {
    var playerNumber: Int
    var betSize: Int
}

class HandTrackerViewModel: CardSelectionProtocol {
    @Published var selectedHand: Hand = .hero
    @Published var cards = [CardModel]()
    @Published var hands: [Hand: [CardModel]] = [.hero: [], .flop: [], .turn: [], .river: []]

    init() {
        cards = Suit.allCases.filter { $0 != .placeholder }.flatMap { suit in
            Rank.allCases.filter { $0 != .placeholder }.map { rank in
                CardModel(suit: suit, rank: rank)
            }
        }
    }

    func addCard(_ card: CardModel, to hand: Hand) {
        guard var handCards = hands[hand], !handCards.contains(card) else { return }

        if hand == .hero && handCards.count < 2 {
            handCards.append(card)
            hands[hand] = handCards
            cards.removeAll { $0 == card }
        }
        else if hand == .flop && handCards.count < 3 {
            handCards.append(card)
            hands[hand] = handCards
            cards.removeAll { $0 == card }
        }
        else if hand == .turn && handCards.count < 1 {
            handCards.append(card)
            hands[hand] = handCards
            cards.removeAll { $0 == card }
        }
        else if hand == .river && handCards.count < 1 {
            handCards.append(card)
            hands[hand] = handCards
            cards.removeAll { $0 == card }
        }
    }

    func removeCard(_ card: CardModel, from hand: Hand) {
        guard var handCards = hands[hand] else { return }
        handCards.removeAll { $0 == card }
        hands[hand] = handCards

        if !cards.contains(card) {
            cards.append(card)
        }
    }
    
    // Action related tracking
    @Published var actions = [Action]()
    @Published var currentPlayer = 1
    
    func goBack() {
        guard !actions.isEmpty else { return }
        actions.removeLast()
        currentPlayer = max(1, currentPlayer - 1)
    }
    
    func raise(betSize: Int) {
        addAction(playerNumber: currentPlayer, betSize: betSize)
        advancePlayer()
    }
    
    func call() {
        let defaultBetSize = 1
        
        let lastBetSize = actions.last(where: { $0.betSize > 0 })?.betSize ?? defaultBetSize
        
        addAction(playerNumber: currentPlayer, betSize: lastBetSize)
        advancePlayer()
    }

    
    func fold() {
        addAction(playerNumber: currentPlayer, betSize: 0)
        advancePlayer()
    }
    
    func endStreet() {
        // print all the published variables
        print(hands)
        print(actions)
    }
    
    private func addAction(playerNumber: Int, betSize: Int) {
        let action = Action(playerNumber: playerNumber, betSize: betSize)
        actions.append(action)
    }
    
    private func advancePlayer() {
        currentPlayer += 1
    }
}
