//
//  CardPickerView.swift
//  Poker Calculator
//
//  Created by Khoi Nguyen on 4/18/23.
//

import SwiftUI

struct CardPickerView: View {
    @ObservedObject var contentVM : ContentViewModel
    
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
                            if contentVM.cards.contains(where: { $0 == card }) {
                                CardView(card: card)
                                    .onTapGesture {
                                        contentVM.addCard(card: card)
                                        contentVM.selectedHand = .none
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

struct CardPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CardPickerView(contentVM: ContentViewModel())
    }
}
