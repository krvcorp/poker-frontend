import SwiftUI

struct EquityCalculatorView: View {
    @StateObject var equityCalculatorVM = EquityCalculatorViewModel()

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Text("Player 1: \(equityCalculatorVM.player1Odds, specifier: "%.2f")%")
                        .foregroundColor(equityCalculatorVM.player1Odds > equityCalculatorVM.player2Odds ? .green : .red)
                    Text("Player 2: \(equityCalculatorVM.player2Odds, specifier: "%.2f")%")
                        .foregroundColor(equityCalculatorVM.player2Odds > equityCalculatorVM.player1Odds ? .green : .red)
                }
                
                Text("Tie: \(equityCalculatorVM.tieOdds, specifier: "%.2f")%")
                
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
            
            cardSection(for: .player2, title: "Player 2")
            cardSection(for: .table, title: "Table")
            cardSection(for: .player1, title: "Player 1", isBottom: true)
        }
        .sheet(isPresented: $equityCalculatorVM.selectedHand.isNotNone) {
            CardPickerView(viewModel: equityCalculatorVM)
                .presentationDetents([.large])
        }
    }
    
    @ViewBuilder
    private func cardSection(for hand: Hand, title: String, isBottom: Bool = false) -> some View {
        let cards = equityCalculatorVM.hands[hand] ?? []
        let placeholdersCount = hand == .table ? max(0, 5 - cards.count) : max(0, 2 - cards.count)
        let placeholders = Array(repeating: CardModel.placeholder(), count: placeholdersCount)
        
        VStack {
            if !isBottom {
                HStack {
                    Spacer()
                    Text(title)
                        .font(.title3.bold())
                    Spacer()
                }
            }
            
            HStack {
                ForEach(cards + placeholders) { card in
                    CardView(card: card)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            if card.isPlaceholder {
                                equityCalculatorVM.selectedHand = hand
                            } else {
                                equityCalculatorVM.removeCard(card, from: hand)
                            }
                        }
                }
            }
            
            if isBottom {
                HStack {
                    Spacer()
                    Text(title)
                        .font(.title3.bold())
                    Spacer()
                }
            }
        }
    }
}
