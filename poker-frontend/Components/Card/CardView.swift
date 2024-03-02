//
//  CardView.swift
//  Poker Calculator
//
//  Created by Khoi Nguyen on 4/18/23.
//

import SwiftUI

struct CardView: View {
    let card: CardModel

    var body: some View {
        // align in the middle with bold font
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(card.rank.rawValue)
                Spacer()
            }

            HStack {
                Spacer()
                switch card.suit {
                case .spades:
                    Text("♠️")
                case .hearts:
                    Text("♥️")
                case .diamonds:
                    Text("♦️")
                case .clubs:
                    Text("♣️")
                default:
                    Text("")
                }
                Spacer()
            }
        }
        .font(.system(size: 20, weight: .bold, design: .default))
        .frame(width: UIScreen.main.bounds.width / 7, height: UIScreen.main.bounds.width / 7 * 1.55)
        .foregroundColor(card.isPlaceholder ? Color.gray : (card.suit == .spades || card.suit == .clubs ? Color.black : Color.red))
        .background(card.isPlaceholder ? Color.gray : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: CardModel(suit: Suit.spades, rank: Rank.ace))
    }
}
