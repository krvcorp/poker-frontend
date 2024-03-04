//
//  HandTrackerViewModel.swift
//  poker-frontend
//
//  Created by Khoi Nguyen on 3/1/24.
//

import Foundation

struct PlayerState {
    var playerNumber: Int
    var isFolded: Bool
    var position: Position
}

class HandTrackerViewModel: CardSelectionProtocol {
    @Published var selectedHand: Hand = .hero
    @Published var cards = [CardModel]()
    @Published var hands: [Hand: [CardModel]] = [.hero: [], .flop: [], .turn: [], .river: []]

    @Published var actions = [Action]()

    @Published var currentPlayer: Int = 1
    private var currentStreet: Street = .preflop

    private let maxPlayers: Int = 9
    @Published var playerStates: [PlayerState] = []

    @Published var isHeroNum = -1
    @Published var isCardPickerPresented = false

    @Published var lastBetSize: Int = 1

    init() {
        initializePlayerStates()

        cards = Suit.allCases.filter { $0 != .placeholder }.flatMap { suit in
            Rank.allCases.filter { $0 != .placeholder }.map { rank in
                CardModel(suit: suit, rank: rank)
            }
        }
    }
    
    // This needs to change based on the number of players actually in the hand
    private func initializePlayerStates() {
        playerStates = [
            PlayerState(playerNumber: 1, isFolded: false, position: .utg),
            PlayerState(playerNumber: 2, isFolded: false, position: .utg1),
            PlayerState(playerNumber: 3, isFolded: false, position: .utg2),
            PlayerState(playerNumber: 4, isFolded: false, position: .lojack),
            PlayerState(playerNumber: 5, isFolded: false, position: .hijack),
            PlayerState(playerNumber: 6, isFolded: false, position: .cutoff),
            PlayerState(playerNumber: 7, isFolded: false, position: .button),
            PlayerState(playerNumber: 8, isFolded: false, position: .smallBlind),
            PlayerState(playerNumber: 9, isFolded: false, position: .bigBlind),
        ]
    }

    func addCard(_ card: CardModel, to hand: Hand) {
        guard var handCards = hands[hand], !handCards.contains(card) else { return }

        if hand == .hero && handCards.count < 2 {
            handCards.append(card)
            hands[hand] = handCards

            if handCards.count == 2 {
                isHeroNum = currentPlayer
            }

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

    func hasBeenRaiseOnCurrentStreet() -> Bool {
        return actions.contains(where: { $0.actionType == .raise && $0.street == currentStreet })
    }

    func shouldShowCallButton() -> Bool {
        if currentStreet == .preflop {
            return true
        }
        
        return hasBeenRaiseOnCurrentStreet()
    }
    
    func check() {
        let canCheck = currentStreet != .preflop && !actions.contains { $0.street == currentStreet && $0.actionType == .raise }
        guard canCheck else { return }
        
        addAction(playerNumber: currentPlayer, betSize: 0, actionType: .check, street: currentStreet)
    }

    func call() {
        let defaultBetSize: Int = 1
        let lastBetSize = actions.last(where: { $0.street == currentStreet && $0.betSize > 0 })?.betSize ?? defaultBetSize
        addAction(playerNumber: currentPlayer, betSize: lastBetSize, actionType: .call, street: currentStreet)
    }

    func raise(betSize: Int) {
        guard betSize > 0 else {
            print("Raise amount must be positive.")
            return
        }
        
        let minimumTotalRaiseToAmount = calculateMinimumRaiseAmount()
        
        if betSize < minimumTotalRaiseToAmount {
            print("Total raise must be at least \(minimumTotalRaiseToAmount).")
            return
        }
        
        addAction(playerNumber: currentPlayer, betSize: betSize, actionType: .raise, street: currentStreet)
        updateLastBetSize()
    }

    func calculateMinimumRaiseAmount() -> Int {
        // Assuming the last raise amount is the difference between the last bet size and the one before it.
        let lastBetOrRaise = actions.filter { $0.street == currentStreet && ($0.actionType == .raise || $0.actionType == .raise) }.last?.betSize ?? 0
        let previousBetOrRaise = actions.filter { $0.street == currentStreet && ($0.actionType == .raise || $0.actionType == .raise) }.dropLast().last?.betSize ?? 0
        
        let lastRaiseAmount = lastBetOrRaise - previousBetOrRaise
        // Assuming the minimum raise amount is the same as the last raise amount or a defined minimum raise, e.g., the big blind.
        let minimumRaiseAmount = max(lastRaiseAmount, 1) // Replace '1' with your game's minimum raise amount if different.
        
        // The total amount to "raise to" includes the last bet or raise plus the minimum raise amount.
        return lastBetOrRaise + minimumRaiseAmount
    }

    func updateLastBetSize() {
        lastBetSize = actions.last(where: { $0.street == currentStreet && $0.betSize > 0 })?.betSize ?? 1
    }


    func fold() {
        addAction(playerNumber: currentPlayer, betSize: 0, actionType: .fold, street: currentStreet)
    }

    private func addAction(playerNumber: Int, betSize: Int, actionType: ActionType, street: Street) {
        let isHero = (isHeroNum == playerNumber)
        
        let action = Action(playerNumber: playerNumber, betSize: betSize, actionType: actionType, position: .utg, isHero: isHero, street: street)
        actions.append(action)

        if isHero {
            print("Hero \(playerNumber) did \(actionType) with bet size \(betSize) on \(street)")
        } else {
            print("Player \(playerNumber) did \(actionType) with bet size \(betSize) on \(street)")
        }

        if actionType == .fold {
            playerStates[playerNumber - 1].isFolded = true
        }

        advancePlayer()
    }


    private func advancePlayer() {
        // Adjust for 0-based indexing by subtracting 1 from currentPlayer.
        var nextPlayerIndex = (currentPlayer - 1 + 1) % playerStates.count // Start from the next player in line
        let startIndex = nextPlayerIndex // Remember the starting index to prevent infinite loops

        var foundActivePlayer = false

        // Loop until an active (not folded) player is found or all players are checked
        while !foundActivePlayer {
            if !playerStates[nextPlayerIndex].isFolded {
                foundActivePlayer = true
                // Adjust back to 1-based indexing for currentPlayer.
                currentPlayer = nextPlayerIndex + 1
                break
            }
            nextPlayerIndex = (nextPlayerIndex + 1) % playerStates.count

            // If we've checked all players and returned to the start, break to prevent infinite loop
            if nextPlayerIndex == startIndex {
                break
            }
        }

        // After finding the next active player or completing the loop, check the number of active players.
        let activePlayersCount = playerStates.filter { !$0.isFolded }.count

        // If only one active player is left, end the hand.
        if activePlayersCount == 1 {
            endHand()
        } else if foundActivePlayer && shouldEndStreet() {
            // If more than one active player is left, check if the street should be ended.
            endStreet()
        } else {
            print("Current Player after advance: \(currentPlayer)")
        }
    }


    // Assumes existence of `actions` array storing all actions in the current hand
    // and `currentStreet` variable indicating the current phase of the hand.

    private func shouldEndStreet() -> Bool {
        // Filter actions for the current street
        let currentStreetActions = actions.filter { $0.street == currentStreet }
        
        // No action to process, cannot end street
        if currentStreetActions.isEmpty {
            return false
        }
        
        // Assuming currentStreetActions is an array of Action structs.

        // Find the index of the last raise action on the current street, if any.
        if let lastRaiseIndex = currentStreetActions.lastIndex(where: { $0.actionType == .raise }) {
            // Actions after the last raise. We include actions by starting from the action immediately after the last raise.
            let actionsAfterLastRaise = currentStreetActions[(lastRaiseIndex)...]

            // Get unique player numbers who have acted after the last raise
            let playersActedAfterLastRaise = Set(actionsAfterLastRaise.map { $0.playerNumber })
            
            // Check if these players include all active (non-folded) players
            let activePlayers = Set(playerStates.filter { !$0.isFolded }.map { $0.playerNumber })
            
            // Determine if all active players have acted since the last raise.
            return activePlayers.isSubset(of: playersActedAfterLastRaise)
        } else {
            // If there was no raise on the current street, check if all active players have acted.
            // This situation can occur if the action is checked around on the flop, turn, or river.
            let playersActed = Set(currentStreetActions.map { $0.playerNumber })
            let activePlayers = Set(playerStates.filter { !$0.isFolded }.map { $0.playerNumber })
            
            // Determine if all active players have acted.
            return activePlayers.isSubset(of: playersActed)
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
        case .river: return .preflop
        }
    }

    func endStreet() {
        if !canProceedToNextStreet() {
            print("Cannot end street. Required cards are not inputted.")
            return
        }

        if currentStreet == .river {
            endHand()
            return
        } else {
            currentStreet = nextStreet(currentStreet)
            // Show the next street's cards
            isCardPickerPresented = true

            // Reset currentPlayer for the new street, starting the search from the small blind's position
            // which is the second to last in playerStates for active status.
            var indexToCheck = playerStates.count - 2 // Start from small blind's position

            var foundActivePlayer = false
            while !foundActivePlayer {
                if !playerStates[indexToCheck].isFolded {
                    foundActivePlayer = true
                    currentPlayer = playerStates[indexToCheck].playerNumber // Set currentPlayer to the active player's number
                    break
                }
                indexToCheck = (indexToCheck + 1) % playerStates.count // Cycle through the array if needed
            }

            if !foundActivePlayer {
                // Fallback to the first player if no active player found in the cycle, which is highly unlikely
                // because it means all players have folded except one.
                currentPlayer = playerStates.first?.playerNumber ?? 1
            }

            print("Moving to \(currentStreet). Active players: \(playerStates.filter { !$0.isFolded }.map { $0.playerNumber })")
        }
    }

    func endHand() {
        print("Hand ended. Final actions:")
        var lastRaiseAmount: Int = 0
        var raiseSequence = 0 // Track the sequence of raises
        var currentActionStreet: Street? = nil // Track the current street of actions for comparison

        for action in actions {
            // Check if the street has changed (indicating a new street of actions is starting)
            if currentActionStreet != action.street {
                // Map the currentActionStreet to Hand before printing the board state
                if let streetHand = mapStreetToHand(street: currentActionStreet), let cards = hands[streetHand], !cards.isEmpty {
                    let cardsDescription = cards.map { $0.description }.joined(separator: " ")
                    print("\(streetHand): \(cardsDescription)")
                }
                currentActionStreet = action.street
            }

            let playerOrHero = action.playerNumber == isHeroNum ? "Hero" : playerStates[action.playerNumber - 1].position.description + " (Player \(action.playerNumber))"
            var actionDescription = ""
            switch action.actionType {
            case .fold:
                actionDescription = "\(playerOrHero) Folds"
            case .check:
                actionDescription = "\(playerOrHero) Checks"
            case .call:
                actionDescription = "\(playerOrHero) Calls \(action.betSize)"
            case .raise:
                if action.betSize > lastRaiseAmount {
                    lastRaiseAmount = action.betSize
                    raiseSequence = currentActionStreet == action.street ? raiseSequence + 1 : 1 // Reset or increment raiseSequence
                    let betSequence = raiseSequence == 1 ? "opens" : "re-raises"
                    actionDescription = "\(playerOrHero) \(betSequence) \(action.betSize)"
                }
            }

            print(actionDescription)
        }

        // After all actions, print the final street's board state if there's any
        if let finalStreetHand = mapStreetToHand(street: currentActionStreet), let cards = hands[finalStreetHand], !cards.isEmpty {
            let cardsDescription = cards.map { $0.description }.joined(separator: " ")
            print("\(finalStreetHand): \(cardsDescription)")
        }

        initializePlayerStates()
        actions.removeAll()
        currentPlayer = 1
        currentStreet = .preflop
        isHeroNum = -1
    }

    func mapStreetToHand(street: Street?) -> Hand? {
        switch street {
        case .preflop: return nil // Preflop doesn't have a board
        case .flop: return .flop
        case .turn: return .turn
        case .river: return .river
        case .none: return nil
        }
    }
}
