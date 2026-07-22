//
//  DeviceRepository.swift
//  TrailPoint
//

import Foundation

protocol DeviceRepository {
    func getDevices() async throws -> [Device]
    func fetchStatus(for deviceID: UUID) async throws -> Device
}

final class RemoteDeviceRepository: DeviceRepository {

    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func getDevices() async throws -> [Device] {
        do {
            let data = try await client.get(path: "devices")
            return try JSONDecoder().decode([Device].self, from: data)
        } catch is CancellationError {
            throw CancellationError()
        } catch RepositoryError.network {
            return []
        }
    }

    func fetchStatus(for deviceID: UUID) async throws -> Device {
        let data = try await client.get(path: "devices/\(deviceID.uuidString)")
        return try JSONDecoder().decode(Device.self, from: data)
    }
}
