//
//  MessageRepository.swift
//  TrailPoint
//

import Foundation

protocol MessageRepository {
    func fetchMessages() async throws -> [Message]
}

final class RemoteMessageRepository: MessageRepository {

    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func fetchMessages() async throws -> [Message] {
        do {
            let data = try await client.get(path: "messages")
            return try JSONDecoder().decode([Message].self, from: data)
        } catch is CancellationError {
            throw CancellationError()
        } catch RepositoryError.network {
            return []
        }
    }
}
