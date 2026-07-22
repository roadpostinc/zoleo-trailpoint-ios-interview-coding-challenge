//
//  WireFixture.swift
//  TrailPointTests
//

import Foundation

enum WireFixture {

    struct DevicePayload: Encodable {
        let id: UUID
        let name: String
        let hasActiveSosAlert: Bool
        let lastSeen: Int64
    }

    struct MessagePayload: Encodable {
        let id: UUID
        let deviceId: UUID
        let type: String
        let body: String
        let timestamp: String
    }

    private struct ErrorPayload: Encodable {
        let error: String
    }

    static func deviceJSON(
        id: UUID = UUID(),
        name: String,
        hasActiveSosAlert: Bool = false,
        lastSeenMillis: Int64
    ) -> DevicePayload {
        DevicePayload(
            id: id,
            name: name,
            hasActiveSosAlert: hasActiveSosAlert,
            lastSeen: lastSeenMillis
        )
    }

    static func messageJSON(
        id: UUID = UUID(),
        deviceId: UUID,
        type: String,
        body: String,
        timestampMillis: Int64
    ) -> MessagePayload {
        MessagePayload(
            id: id,
            deviceId: deviceId,
            type: type,
            body: body,
            timestamp: String(timestampMillis)
        )
    }

    static func data<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }

    static func errorData(_ message: String) -> Data {
        data(ErrorPayload(error: message))
    }

    static func emptyArrayData() -> Data {
        Data("[]".utf8)
    }
}
