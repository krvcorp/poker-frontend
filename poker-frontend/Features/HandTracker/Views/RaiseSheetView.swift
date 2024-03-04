import SwiftUI

struct RaiseSheetView: View {
    @ObservedObject var handTrackerVM: HandTrackerViewModel
    // Raise amount should be the minimum raise amount allowed on the current street obtained from the HandTrackerViewModel
    @State private var raiseAmount: Int = 2
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Raise Amount: \(raiseAmount) BB")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Spacer()
            
            // Adjust raise amount
            HStack(spacing: 40) {
                Group {
                    AdjustButton(label: "-25", action: { adjustRaise(by: -25) })
                    AdjustButton(label: "-5", action: { adjustRaise(by: -5) })
                    AdjustButton(label: "-1", action: { adjustRaise(by: -1) })
                }
                
                Group {
                    AdjustButton(label: "+1", action: { adjustRaise(by: 1) }, isPositive: true)
                    AdjustButton(label: "+5", action: { adjustRaise(by: 5) }, isPositive: true)
                    AdjustButton(label: "+25", action: { adjustRaise(by: 25) }, isPositive: true)
                }
            }
            .padding(.horizontal)
            
            // Quick set raise amount
            HStack(spacing: 20) {
                QuickSetButton(label: "3 BB", amount: 3, action: setRaise)
                QuickSetButton(label: "4 BB", amount: 4, action: setRaise)
                QuickSetButton(label: "5 BB", amount: 5, action: setRaise)
            }
            
            Spacer()
            
            // Confirm button
            Button("Confirm Raise") {
                handTrackerVM.raise(betSize: raiseAmount)
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(ConfirmButtonStyle())
            .padding(.bottom)
        }
        .padding()
    }
    
    private func adjustRaise(by amount: Int) {
        raiseAmount += amount
        if raiseAmount < 0 { raiseAmount = 0 } // Prevent negative raises
    }
    
    private func setRaise(to bb: Int) {
        raiseAmount = bb
    }
}

struct AdjustButton: View {
    var label: String
    var action: () -> Void
    var isPositive: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(width: 90)
                .background(isPositive ? Color.green : Color.red)
                .cornerRadius(10)
        }
    }
}


struct QuickSetButton: View {
    var label: String
    var amount: Int
    var action: (Int) -> Void
    
    var body: some View {
        Button(action: { action(amount) }) {
            Text(label)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(width: 90)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}

struct ConfirmButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
