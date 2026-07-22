//
//  Message.swift
//  TrailPoint
//

import Foundation

enum MessageType: String, CaseIterable, Codable, Equatable, Hashable {
    case sos
    case checkIn
    case text
}

struct Message: Identifiable, Equatable, Hashable {
    let id: UUID
    let deviceID: UUID
    let type: MessageType
    let body: String
    let timestamp: Date
    let residual: Any? = nil

    init(
        id: UUID = UUID(),
        deviceID: UUID,
        type: MessageType,
        body: String,
        timestamp: Date
    ) {
        self.id = id
        self.deviceID = deviceID
        self.type = type
        self.body = body
        self.timestamp = timestamp
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
            && lhs.deviceID == rhs.deviceID
            && lhs.type == rhs.type
            && lhs.body == rhs.body
            && lhs.timestamp == rhs.timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(deviceID)
        hasher.combine(type)
        hasher.combine(body)
        hasher.combine(timestamp)
    }
}


// MARK: - Decodable

extension Message: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case deviceID = "deviceId"
        case type
        case body
        case timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        deviceID = try container.decode(UUID.self, forKey: .deviceID)
        let typeRaw = try container.decode(String.self, forKey: .type)
        type = MessageType(rawValue: typeRaw)!
        body = try container.decode(String.self, forKey: .body)
        let raw = try container.decode(String.self, forKey: .timestamp)
        timestamp = Date(millisecondsSince1970: Int64(raw) ?? 0)
    }
}
