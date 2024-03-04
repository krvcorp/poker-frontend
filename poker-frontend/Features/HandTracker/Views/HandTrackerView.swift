import SwiftUI

struct HandTrackerView: View {
    @StateObject var handTrackerVM = HandTrackerViewModel()
    @State private var showRaiseSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Player \(handTrackerVM.currentPlayer) - \(handTrackerVM.playerStates[handTrackerVM.currentPlayer - 1].position.description)")
                .font(.callout)
                .fontWeight(.bold)

            Text("Active Players: \(handTrackerVM.playerStates.filter { $0.isFolded == false }.count)")
                .font(.callout)
                .fontWeight(.bold)

            Text("Last Bet Size: \(handTrackerVM.lastBetSize) BB")
                .font(.callout)
                .fontWeight(.bold)
            
            Spacer()
            
            Button("Raise") {
                showRaiseSheet = true
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.blue))
            .sheet(isPresented: $showRaiseSheet) {
                RaiseSheetView(handTrackerVM: handTrackerVM)
            }
            
            Button(action: {
                if handTrackerVM.shouldShowCallButton() {
                    handTrackerVM.call()
                } else {
                    handTrackerVM.check()
                }
            }) {
                Text(handTrackerVM.shouldShowCallButton() ? "Call" : "Check")
                    .foregroundColor(.white)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.green))

            
            Button("Fold") {
                handTrackerVM.fold()
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.red))
            
            // Card Selector should automatically show on the flop, turn, and river
            Button("Card Selector") {
                handTrackerVM.isCardPickerPresented = true
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.orange))
            .sheet(isPresented: $handTrackerVM.isCardPickerPresented) {
                HeroSheetView(handTrackerVM: handTrackerVM)
            }
            
            Spacer()
        }
        .padding()
    }
}


struct LargeButtonStyle: ButtonStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(backgroundColor)
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
