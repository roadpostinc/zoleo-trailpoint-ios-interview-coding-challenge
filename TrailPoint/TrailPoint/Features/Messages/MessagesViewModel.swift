//
//  MessagesViewModel.swift
//  TrailPoint
//

import Foundation

@MainActor
@Observable
final class MessagesViewModel {

    private(set) var messages: [Message] = []
    private(set) var loadErrorMessage: String?

    private let repository: MessageRepository

    init(repository: MessageRepository = RemoteMessageRepository()) {
        self.repository = repository
    }

    func refresh() {
        Task {
            do {
                let fetched = try await repository.fetchMessages()
                messages = fetched
                loadErrorMessage = nil
            } catch is CancellationError {
                return
            } catch {
                messages = []
            }
        }
    }
}
