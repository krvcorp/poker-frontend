import SwiftUI

struct HeroSheetView: View {
    @ObservedObject var handTrackerVM: HandTrackerViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Select Your Cards")
                .font(.headline)
                .padding()

            cardSection(for: .hero, title: "Hero Hand", requiredCount: 2)
            
            if handTrackerVM.hands[.hero]?.count == 2 {
                cardSection(for: .flop, title: "Flop", requiredCount: 3)
            }
            
            if handTrackerVM.hands[.flop]?.count == 3 {
                cardSection(for: .turn, title: "Turn", requiredCount: 1)
            }
            
            if handTrackerVM.hands[.turn]?.count == 1 {
                cardSection(for: .river, title: "River", requiredCount: 1)
            }
        }
        .sheet(isPresented: $isCardPickerPresented) {
            CardPickerView(viewModel: handTrackerVM)
        }
        .onChange(of: handTrackerVM.hands) { _ in
            if handTrackerVM.hands[.hero]?.count == 2, handTrackerVM.selectedHand == .hero {
                presentationMode.wrappedValue.dismiss()
            } else if handTrackerVM.hands[.flop]?.count == 3, handTrackerVM.selectedHand == .flop {
                presentationMode.wrappedValue.dismiss()
            } else if handTrackerVM.hands[.turn]?.count == 1, handTrackerVM.selectedHand == .turn {
                presentationMode.wrappedValue.dismiss()
            } else if handTrackerVM.hands[.river]?.count == 1, handTrackerVM.selectedHand == .river {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    @ViewBuilder
    private func cardSection(for hand: Hand, title: String, requiredCount: Int) -> some View {
        let cards = handTrackerVM.hands[hand] ?? []
        let placeholdersCount = max(0, requiredCount - cards.count)
        let placeholders = Array(repeating: CardModel.placeholder(), count: placeholdersCount)
        
        VStack {
            Text(title)
                .font(.title3.bold())
                .padding(.bottom, 5)
            
            HStack {
                ForEach(cards + placeholders) { card in
                    CardView(card: card)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            if card.isPlaceholder {
                                handTrackerVM.selectedHand = hand
                                isCardPickerPresented = true
                            } else {
                                handTrackerVM.removeCard(card, from: hand)
                            }
                        }
                }
            }
        }
        .padding(.vertical)
    }
    
    // State to manage the presentation of the CardPickerView
    @State private var isCardPickerPresented = false
}
