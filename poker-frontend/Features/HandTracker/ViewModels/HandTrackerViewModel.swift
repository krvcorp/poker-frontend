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
    @Published var selectedHand: Hand = .none
    @Published var player1Cards = [CardModel]()
    @Published var player2Cards = [CardModel]()
    @Published var tableCards = [CardModel]()
    
    @Published var cards = [CardModel]()

    func addCard(card: CardModel) {
        if !heroCards.contains(card) && heroCards.count < 2 { // Assuming a hero can have up to 2 cards
            heroCards.append(card)
            cards = cards.filter { $0 != card }
        }
    }
    
    func removeCard(card: CardModel) {
        heroCards.removeAll { $0 == card }
        if !cards.contains(card) {
            cards.append(card)
        }
    }
    
    func removeCard(card: CardModel, from hand: Hand) {
        print("will not be used")
    }
    
    @Published var actions = [Action]()
    @Published var currentPlayer = 1
    @Published var heroCards = [CardModel]()

    
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
        addAction(playerNumber: currentPlayer, betSize: 1)
        advancePlayer()
    }
    
    func fold() {
        addAction(playerNumber: currentPlayer, betSize: 0)
        advancePlayer()
    }
    
    func endStreet() {
        advancePlayer()
    }
    
    private func addAction(playerNumber: Int, betSize: Int) {
        let action = Action(playerNumber: playerNumber, betSize: betSize)
        actions.append(action)
    }
    
    private func advancePlayer() {
        currentPlayer += 1
    }
}
