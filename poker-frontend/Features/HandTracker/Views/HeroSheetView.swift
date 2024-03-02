//
//  HeroSheetView.swift
//  poker-frontend
//
//  Created by Khoi Nguyen on 3/1/24.
//

import SwiftUI



struct HeroSheetView: View {
    @ObservedObject var handTrackerVM : HandTrackerViewModel
    var body: some View {
        CardPickerView(viewModel: handTrackerVM)
    }
}
