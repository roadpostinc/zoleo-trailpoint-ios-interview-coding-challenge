//
//  DeviceListView.swift
//  TrailPoint
//

import SwiftUI

struct DeviceListView: View {
    @State private var viewModel = DeviceListViewModel()

    var body: some View {
        NavigationStack {
            Group {
              List(viewModel.devices) { device in
                NavigationLink(value: device) {
                  VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                      .font(.headline)
                    Text("Last seen: \(device.lastSeen.formatted(date: .abbreviated, time: .shortened))")
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                }
              }
            }
            .navigationTitle("Devices")
            .navigationDestination(for: Device.self) { device in
                DeviceDetailView(device: device)
            }
        }
        .task {
            await viewModel.loadDevices()
        }
    }
}

#Preview {
    DeviceListView()
}
