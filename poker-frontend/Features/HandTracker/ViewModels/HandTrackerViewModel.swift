//
//  HandTrackerViewModel.swift
//  poker-frontend
//
//  Created by Khoi Nguyen on 3/1/24.
//

import Foundation


class HandTrackerViewModel: CardSelectionProtocol {
    @Published var selectedHand: Hand = .hero
    @Published var cards = [CardModel]()
    @Published var hands: [Hand: [CardModel]] = [.hero: [], .flop: [], .turn: [], .river: []]
    @Published var actions = [Action]()
    @Published var currentPlayer: Int = 1
    private var currentStreet: Street = .preflop
    private let maxPlayers: Int = 9
    private var activePlayerNumbers: [Int] = []

    init() {
        activePlayerNumbers = Array(1...maxPlayers) // Initially, all player numbers are active
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
    
    func goBack() {
        guard !actions.isEmpty else { return }
        actions.removeLast()
        currentPlayer = max(1, currentPlayer - 1)
    }
    

    func check() {
        addAction(playerNumber: currentPlayer, betSize: 0, actionType: .check, street: currentStreet)
    }

    func call() {
        let defaultBetSize: Int = 1
        let lastBetSize = actions.last(where: { $0.betSize > 0 })?.betSize ?? defaultBetSize
        addAction(playerNumber: currentPlayer, betSize: lastBetSize, actionType: .call, street: currentStreet)
    }

    func raise(betSize: Int) {
        addAction(playerNumber: currentPlayer, betSize: betSize, actionType: .raise, street: currentStreet)
    }

    func fold() {
        addAction(playerNumber: currentPlayer, betSize: 0, actionType: .fold, street: currentStreet)
    }

    private func addAction(playerNumber: Int, betSize: Int, actionType: ActionType, street: Street) {
        // Check for hero's cards in preflop or community cards in later streets
        if !canProceedToNextStreet() {
            print("Cannot proceed to the next street. Required cards are not inputted.")
            return
        }

        let action = Action(playerNumber: playerNumber, betSize: betSize, actionType: actionType, position: .utg, // Position to be adjusted later
                            isHero: false, street: street)
        actions.append(action)
        if actionType == .fold {
            activePlayerNumbers = activePlayerNumbers.filter { $0 != playerNumber }
        }

        print("Player \(playerNumber) did \(actionType) with bet size \(betSize) on \(street)")

        advancePlayer()
    }

    private func advancePlayer() {
        if let currentIndex = activePlayerNumbers.firstIndex(of: currentPlayer), currentIndex + 1 < activePlayerNumbers.count {
            currentPlayer = activePlayerNumbers[currentIndex + 1]
        } else {
            endStreet()
        }
    }

    private func adjustPlayerPositions() {
        let positionsInOrder: [Position] = [.utg, .utg1, .utg2, .lojack, .hijack, .cutoff, .button, .smallBlind, .bigBlind]
        let numberOfActivePlayers = activePlayerNumbers.count
        let adjustedPositions = Array(positionsInOrder.prefix(numberOfActivePlayers))

        actions = actions.map { action in
            var newAction = action
            if let index = activePlayerNumbers.firstIndex(of: action.playerNumber) {
                newAction.position = adjustedPositions[index % numberOfActivePlayers]
            }
            return newAction
        }
    }

    private func canProceedToNextStreet() -> Bool {
        switch currentStreet {
        case .preflop:
            return hands[.hero]?.count ?? 0 == 2
        case .flop:
            return hands[.flop]?.count ?? 0 == 3
        case .turn:
            return hands[.turn]?.count ?? 0 == 1
        case .river:
            return hands[.river]?.count ?? 0 == 1
        default:
            return false
        }
    }

    private func nextStreet(_ street: Street) -> Street {
        switch street {
        case .preflop: return .flop
        case .flop: return .turn
        case .turn: return .river
        case .river: return .preflop // or handle end of hand
        }
    }

    func endStreet() {
        if !canProceedToNextStreet() {
            print("Cannot end street. Required cards are not inputted.")
            return
        }

        adjustPlayerPositions()

        if currentStreet == .river {
            endHand()
            return
        } else {
            currentStreet = nextStreet(currentStreet)
            print("Moving to \(currentStreet). Active players: \(activePlayerNumbers.count)")
        }
    }

    func endHand() {
        print("Hand ended. Final actions:")
        for action in actions {
            print("Player \(action.playerNumber) \(action.actionType) as \(action.position) on \(action.street)")
        }
        actions.removeAll()
        currentPlayer = 1
        currentStreet = .preflop
    }
}
