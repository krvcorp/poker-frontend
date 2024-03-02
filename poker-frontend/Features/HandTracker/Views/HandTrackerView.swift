import SwiftUI

struct HandTrackerView: View {
    @StateObject var handTrackerVM = HandTrackerViewModel()
    @State private var showRaiseSheet = false
    @State private var showHeroSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Player \(handTrackerVM.currentPlayer)")
                .font(.largeTitle) // Make the title larger
                .fontWeight(.bold)
            
            if handTrackerVM.actions.count > 0 { // Show back button if there are actions to undo
                Button(action: { handTrackerVM.goBack() }) {
                    Text("Back")
                        .font(.title) // Bigger font for the button text
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Ensure consistent height and full width
                        .background(Color.blue)
                        .cornerRadius(10) // Rounded corners for a modern look
                }
            }
            
            Spacer()
            
            Button("Raise") {
                showRaiseSheet = true
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.blue))
            .sheet(isPresented: $showRaiseSheet) {
                // Assuming RaiseSheetView exists and is correctly implemented.
                RaiseSheetView(handTrackerVM: handTrackerVM)
            }
            
            Button("Call") {
                handTrackerVM.call()
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.green))
            
            Button("Fold") {
                handTrackerVM.fold()
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.gray))
            
            Button("Me") {
                showHeroSheet = true
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.orange))
            .sheet(isPresented: $showHeroSheet) {
                HeroSheetView(handTrackerVM: handTrackerVM)
            }
            
            Button("End Street") {
                handTrackerVM.endStreet()
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.purple))
            
            Spacer()
        }
        .padding()
    }
}


struct LargeButtonStyle: ButtonStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title2) // Increase font size
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 60) // Make buttons larger
            .background(backgroundColor)
            .cornerRadius(10) // Rounded corners for buttons
            .padding(.horizontal) // Add some horizontal padding
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Slight scale effect on press
    }
}
