//
//  MessageListView.swift
//  TrailPoint
//

import SwiftUI

struct MessageListView: View {
    @State private var viewModel = MessagesViewModel()

    var body: some View {
        NavigationStack {
            Group {
              List {
                ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { _, message in
                  MessageRow(message: message)
                }
              }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

private struct MessageRow: View {
    let message: Message

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.type.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(message.body)
                .font(.body)
            Text(message.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    MessageListView()
}
