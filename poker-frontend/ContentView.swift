//
//  ContentView.swift
//  Poker
//
//  Created by Khoi Nguyen on 4/18/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var contentVM = ContentViewModel()

    var body: some View {
        VStack (spacing: 20) {
            VStack {
                HStack {
                    Text("Player 1: \(contentVM.player1Odds, specifier: "%.2f")%")
                        .foregroundColor(contentVM.player1Odds > contentVM.player2Odds ? .green : .red)
                    Text("Player 2: \(contentVM.player2Odds, specifier: "%.2f")%")
                        .foregroundColor(contentVM.player2Odds > contentVM.player1Odds ? .green : .red)
                    
                }
                
                Text("Tie: \(contentVM.tieOdds, specifier: "%.2f")%")

                // add styling to the calculate button
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    contentVM.calculateWinningProbability()
                }, label: {
                    Text("Calculate")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                })
            }
            .fontWeight(.bold)
            .padding()
            .background(Color.gray.opacity(0.25))
            .cornerRadius(15)
            .padding()
            .padding(.bottom, 25)
            
            VStack {
                HStack {
                    Spacer()
                    Text("Player 2")
                    .font(.title3.bold())
                    Spacer()
                }
                
                HStack {
                    ForEach(contentVM.player2Cards + Array(repeating: CardModel.placeholder(), count: max(0, 2 - contentVM.player2Cards.count))) { card in
                        CardView(card: card)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                                if card.isPlaceholder {
                                    contentVM.selectedHand = .player2
                                } else {
                                    contentVM.removeCard(card: card, hand: .player2)
                                }
                            }
                    }
                }
            }

            HStack {
                ForEach(contentVM.tableCards + Array(repeating: CardModel.placeholder(), count: max(0, 5 - contentVM.tableCards.count))) { card in
                    CardView(card: card)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            if card.isPlaceholder {
                                contentVM.selectedHand = .table
                            } else {
                                contentVM.removeCard(card: card, hand: .table)
                            }
                        }
                }
            }
            VStack {
                HStack {
                    ForEach(contentVM.player1Cards + Array(repeating: CardModel.placeholder(), count: max(0, 2 - contentVM.player1Cards.count))) { card in
                        CardView(card: card)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                                if card.isPlaceholder {
                                    contentVM.selectedHand = .player1
                                } else {
                                    contentVM.removeCard(card: card, hand: .player1)
                                }
                            }
                    }
                }
                HStack {
                    Spacer()
                    Text("Player 1")
                    .font(.title3.bold())
                    Spacer()
                }
            }

        }
        .sheet(isPresented: $contentVM.selectedHand.isNotNone) {
            CardPickerView(contentVM: contentVM)
                .presentationDetents([.large])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
