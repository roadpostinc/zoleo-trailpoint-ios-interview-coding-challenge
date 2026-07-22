//
//  ContentView.swift
//  TrailPoint
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DeviceListView()
                .tabItem {
                    Label("Devices", systemImage: "antenna.radiowaves.left.and.right")
                }
            MessageListView()
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
        }
    }
}

#Preview {
    ContentView()
}
