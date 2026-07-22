//
//  DeviceDetailView.swift
//  TrailPoint
//

import SwiftUI

struct DeviceDetailView: View {
    @State private var viewModel: DeviceDetailViewModel

    init(device: Device) {
        _viewModel = State(initialValue: DeviceDetailViewModel(device: device))
    }

    var body: some View {
        List {
            Section("Status") {
                LabeledContent("Name", value: viewModel.device.name)
                LabeledContent("Last seen", value: viewModel.device.lastSeen.formatted(date: .abbreviated, time: .shortened))
            }
            if let message = viewModel.refreshErrorMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.device.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await viewModel.refreshStatus() }
                } label: {
                    if viewModel.isRefreshing {
                        ProgressView()
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(viewModel.isRefreshing)
            }
        }
    }
}
