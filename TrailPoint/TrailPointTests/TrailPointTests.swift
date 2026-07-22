//
//  TrailPointTests.swift
//  TrailPointTests
//

import XCTest
@testable import TrailPoint

final class DeviceModelTests: XCTestCase {
    func test_device_defaultsToNoActiveSOSAlert() {
        let device = Device(name: "Quiet Unit", lastSeen: Date())
        XCTAssertFalse(device.hasActiveSOSAlert)
    }
}

final class MessageModelTests: XCTestCase {

    func test_messageType_hasExactlyThreeCases() {
        XCTAssertEqual(Set(MessageType.allCases), [.sos, .checkIn, .text])
    }

}

final class MessagesViewModelBehaviorTests: XCTestCase {

    func test_refreshShowsExpectedMessages() {
        XCTFail("Replace this")
    }

    func test_refreshSurfacesLoadFailure() {
        XCTFail("Replace this")
    }
}
