//
//  APIClient.swift
//  TrailPoint
//
//  Thin HTTP client talking to the local TrailPoint mock server
//  (`mock-server/`, `http://localhost:4747` from the Simulator)
//

import Foundation

protocol APIClientProtocol {
    func get(path: String) async throws -> Data
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()

    static let defaultBaseURL = URL(string: "http://localhost:4747")!

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = APIClient.defaultBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get(path: String) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            try Task.checkCancellation()
            throw RepositoryError.network
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RepositoryError.network
        }

        guard httpResponse.statusCode == 200 else {
            throw RepositoryError.network
        }

        return data
    }
}
