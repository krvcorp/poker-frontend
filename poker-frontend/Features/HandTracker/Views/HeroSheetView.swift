import SwiftUI

struct HeroSheetView: View {
    @ObservedObject var handTrackerVM: HandTrackerViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            if handTrackerVM.hands[.river]?.count == 1 {
                // If the river card is selected, presumably the next steps or summary
            } else if handTrackerVM.hands[.turn]?.count == 1 {
                Text("Select the river card")
                    .font(.title3.bold())
                    .padding(.bottom, 5)
                cardSection(for: .river, title: "River", requiredCount: 1)
            } else if handTrackerVM.hands[.flop]?.count == 3 {
                Text("Select the turn card")
                    .font(.title3.bold())
                    .padding(.bottom, 5)
                cardSection(for: .turn, title: "Turn", requiredCount: 1)
            } else if handTrackerVM.hands[.hero]?.count == 2 {
                Text("Select the flop cards")
                    .font(.title3.bold())
                    .padding(.bottom, 5)
                cardSection(for: .flop, title: "Flop", requiredCount: 3)
            } else {
                Text("Select your hero hand")
                    .font(.title3.bold())
                    .padding(.bottom, 5)
                cardSection(for: .hero, title: "Hero Hand", requiredCount: 2)
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
                ForEach(cards + placeholders, id: \.id) { card in
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
