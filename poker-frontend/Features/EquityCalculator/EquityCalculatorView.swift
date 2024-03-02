//
//  EquityCalculatorView.swift
//  Poker
//
//  Created by Khoi Nguyen on 4/18/23.
//

import SwiftUI

struct EquityCalculatorView: View {
    @StateObject var equityCalculatorVM = EquityCalculatorViewModel()

    var body: some View {
        VStack (spacing: 20) {
            VStack {
                HStack {
                    Text("Player 1: \(equityCalculatorVM.player1Odds, specifier: "%.2f")%")
                        .foregroundColor(equityCalculatorVM.player1Odds > equityCalculatorVM.player2Odds ? .green : .red)
                    Text("Player 2: \(equityCalculatorVM.player2Odds, specifier: "%.2f")%")
                        .foregroundColor(equityCalculatorVM.player2Odds > equityCalculatorVM.player1Odds ? .green : .red)
                    
                }
                
                Text("Tie: \(equityCalculatorVM.tieOdds, specifier: "%.2f")%")

                // add styling to the calculate button
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    equityCalculatorVM.calculateWinningProbability()
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
                    ForEach(equityCalculatorVM.player2Cards + Array(repeating: CardModel.placeholder(), count: max(0, 2 - equityCalculatorVM.player2Cards.count))) { card in
                        CardView(card: card)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                                if card.isPlaceholder {
                                    equityCalculatorVM.selectedHand = .player2
                                } else {
                                    equityCalculatorVM.removeCard(card: card, from: .player2)
                                }
                            }
                    }
                }
            }

            HStack {
                ForEach(equityCalculatorVM.tableCards + Array(repeating: CardModel.placeholder(), count: max(0, 5 - equityCalculatorVM.tableCards.count))) { card in
                    CardView(card: card)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            if card.isPlaceholder {
                                equityCalculatorVM.selectedHand = .table
                            } else {
                                equityCalculatorVM.removeCard(card: card, from: .table)
                            }
                        }
                }
            }
            VStack {
                HStack {
                    ForEach(equityCalculatorVM.player1Cards + Array(repeating: CardModel.placeholder(), count: max(0, 2 - equityCalculatorVM.player1Cards.count))) { card in
                        CardView(card: card)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                                if card.isPlaceholder {
                                    equityCalculatorVM.selectedHand = .player1
                                } else {
                                    equityCalculatorVM.removeCard(card: card, from: .player1)
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
        .sheet(isPresented: $equityCalculatorVM.selectedHand.isNotNone) {
            CardPickerView(viewModel: equityCalculatorVM)
                .presentationDetents([.large])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
