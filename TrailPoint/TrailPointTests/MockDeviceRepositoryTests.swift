//
//  MockDeviceRepositoryTests.swift
//  TrailPointTests
//

import XCTest
@testable import TrailPoint

@MainActor
final class RemoteDeviceRepositoryTests: XCTestCase {

    override func tearDown() {
        StubURLProtocol.stubHandler = nil
        super.tearDown()
    }

    private func makeRepository(handler: @escaping (URLRequest) -> StubURLProtocol.Stub) -> RemoteDeviceRepository {
        StubURLProtocol.stubHandler = handler
        let client = APIClient(session: StubURLProtocol.makeSession())
        return RemoteDeviceRepository(client: client)
    }

    func test_getDevices_successReturnsDecodedDevices() async throws {
        let seeded = [
            WireFixture.deviceJSON(name: "Ridgeline Tracker", hasActiveSosAlert: true, lastSeenMillis: 1_784_210_700_000),
            WireFixture.deviceJSON(name: "Basecamp Beacon", lastSeenMillis: 1_784_195_400_000)
        ]
        let repository = makeRepository { _ in
            StubURLProtocol.Stub(statusCode: 200, data: WireFixture.data(seeded))
        }

        let devices = try await repository.getDevices()

        XCTAssertEqual(devices.count, seeded.count)
        XCTAssertEqual(devices.first?.name, "Ridgeline Tracker")
        XCTAssertTrue(devices.first?.hasActiveSOSAlert ?? false)
    }

    func test_getDevices_serverFailureReturnsEmptyList() async throws {
        let repository = makeRepository { _ in
            StubURLProtocol.Stub(statusCode: 500, data: WireFixture.errorData("Injected failure"))
        }

        let devices = try await repository.getDevices()

        XCTAssertTrue(devices.isEmpty)
    }

    func test_fetchStatus_successReturnsDecodedDevice() async throws {
        let deviceID = UUID()
        let repository = makeRepository { _ in
            StubURLProtocol.Stub(
                statusCode: 200,
                data: WireFixture.data(WireFixture.deviceJSON(id: deviceID, name: "Device A", lastSeenMillis: 1_000))
            )
        }

        let device = try await repository.fetchStatus(for: deviceID)

        XCTAssertEqual(device.id, deviceID)
        XCTAssertEqual(device.lastSeen, Date(millisecondsSince1970: 1_000))
    }
}
