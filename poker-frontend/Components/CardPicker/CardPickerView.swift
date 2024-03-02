//
//  CardPickerView.swift
//  Poker Calculator
//
//  Created by Khoi Nguyen on 4/18/23.
//

import SwiftUI

protocol CardSelectionProtocol: ObservableObject {
    var selectedHand: Hand { get set }
    var cards: [CardModel] { get set }
    var hands: [Hand: [CardModel]] { get set }

    func addCard(_ card: CardModel, to hand: Hand)
    func removeCard(_ card: CardModel, from hand: Hand)
}


extension CardSelectionProtocol {
    // Default implementation for adding a card to a specific hand
    func addCard(_ card: CardModel, to hand: Hand) {
        guard var handCards = hands[hand] else { return }
        handCards.append(card)
        hands[hand] = handCards
    }
    
    // Default implementation for removing a card from a specific hand
    func removeCard(_ card: CardModel, from hand: Hand) {
        guard var handCards = hands[hand] else { return }
        handCards.removeAll { $0 == card }
        hands[hand] = handCards
    }
}



struct CardPickerView<ViewModel: CardSelectionProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Suit.allCases.filter { $0 != .placeholder }, id: \.self) { suit in
                    VStack {
                        ForEach(Rank.allCases.filter { $0 != .placeholder }, id: \.self) { rank in
                            let card = CardModel(suit: suit, rank: rank)
                            CardView(card: card)
                                .opacity(viewModel.cards.contains(where: { $0 == card }) ? 1.0 : 0.25)
                                .onTapGesture {
                                    if viewModel.cards.contains(where: { $0 == card }) {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        viewModel.addCard(card, to: viewModel.selectedHand)
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
        }
    }
}