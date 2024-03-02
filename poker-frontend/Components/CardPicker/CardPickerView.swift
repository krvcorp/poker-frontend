//
//  CardPickerView.swift
//  Poker Calculator
//
//  Created by Khoi Nguyen on 4/18/23.
//

import SwiftUI

protocol CardSelectionProtocol: ObservableObject {
    var selectedHand: Hand { get set }
    var player1Cards: [CardModel] { get set }
    var player2Cards: [CardModel] { get set }
    var tableCards: [CardModel] { get set }
    var cards: [CardModel] { get set }
    func addCard(card: CardModel)
    func removeCard(card: CardModel)
    func removeCard(card: CardModel, from hand: Hand)
}


struct CardPickerView<ViewModel: CardSelectionProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(Suit.allCases.filter { $0 != .placeholder }, id: \.self) { suit in
                    VStack {
                        ForEach(Rank.allCases.filter { $0 != .placeholder }, id: \.self) { rank in
                            let card = CardModel(suit: suit, rank: rank)
                            if viewModel.cards.contains(where: { $0 == card }) {
                                CardView(card: card)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                                        viewModel.addCard(card: card)
                                        if (viewModel.selectedHand == .player1 && viewModel.player1Cards.count == 2) || (viewModel.selectedHand == .player2 && viewModel.player2Cards.count == 2) || (viewModel.selectedHand == .table && viewModel.tableCards.count == 5) {
                                            viewModel.selectedHand = .none
                                        }
                                    }
                            } else {
                                CardView(card: card)
                                    .opacity(0.25)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
