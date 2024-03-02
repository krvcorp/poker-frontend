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
        TabView {
            NavigationView {
                HandTrackerView()
                    .navigationTitle("Hand Tracker")
            }
            .tabItem {
                Image(systemName: "hand.raised")
                Text("Hand Tracker")
            }
            NavigationView {
                EquityCalculatorView()
                    .navigationTitle("Equity Calculator")
            }
            .tabItem {
                Image(systemName: "percent")
                Text("Equity Calculator")
            }
        }
    }
}
