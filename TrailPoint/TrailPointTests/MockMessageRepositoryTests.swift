//
//  MockMessageRepositoryTests.swift
//  TrailPointTests
//

import XCTest
@testable import TrailPoint

@MainActor
final class RemoteMessageRepositoryTests: XCTestCase {

    override func tearDown() {
        StubURLProtocol.stubHandler = nil
        super.tearDown()
    }

    private func makeRepository(handler: @escaping (URLRequest) -> StubURLProtocol.Stub) -> RemoteMessageRepository {
        StubURLProtocol.stubHandler = handler
        let client = APIClient(session: StubURLProtocol.makeSession())
        return RemoteMessageRepository(client: client)
    }

    func test_fetchMessages_successReturnsAllMessages() async throws {
        let deviceID = UUID()
        let seeded = [
            WireFixture.messageJSON(deviceId: deviceID, type: "sos", body: "SOS", timestampMillis: 100),
            WireFixture.messageJSON(deviceId: deviceID, type: "text", body: "All good", timestampMillis: 200)
        ]
        let repository = makeRepository { request in
            XCTAssertEqual(request.url?.path, "/messages")
            return StubURLProtocol.Stub(statusCode: 200, data: WireFixture.data(seeded))
        }

        let messages = try await repository.fetchMessages()

        XCTAssertEqual(messages.count, seeded.count)
        XCTAssertEqual(messages.map(\.timestamp), [
            Date(millisecondsSince1970: 100),
            Date(millisecondsSince1970: 200)
        ])
    }

    func test_fetchMessages_emptyResponseReturnsEmptyList() async throws {
        let repository = makeRepository { _ in
            StubURLProtocol.Stub(statusCode: 200, data: WireFixture.emptyArrayData())
        }

        let messages = try await repository.fetchMessages()

        XCTAssertTrue(messages.isEmpty)
    }

    func test_fetchMessages_serverFailureReturnsEmptyList() async throws {
        let repository = makeRepository { _ in
            StubURLProtocol.Stub(statusCode: 500, data: WireFixture.errorData("Injected failure"))
        }

        let messages = try await repository.fetchMessages()

        XCTAssertTrue(messages.isEmpty)
    }
}
