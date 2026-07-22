//
//  Device.swift
//  TrailPoint
//

import Foundation

struct Device: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var hasActiveSOSAlert: Bool
    var lastSeen: Date

    init(
        id: UUID = UUID(),
        name: String,
        hasActiveSOSAlert: Bool = false,
        lastSeen: Date
    ) {
        self.id = id
        self.name = name
        self.hasActiveSOSAlert = hasActiveSOSAlert
        self.lastSeen = lastSeen
    }
}

// MARK: - Decodable

extension Device: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case hasActiveSOSAlert = "hasActiveSosAlert"
        case lastSeen
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        hasActiveSOSAlert = try container.decode(Bool.self, forKey: .hasActiveSOSAlert)
        let lastSeenMilliseconds = try container.decode(Int64.self, forKey: .lastSeen)
        lastSeen = Date(millisecondsSince1970: lastSeenMilliseconds)
    }
}
