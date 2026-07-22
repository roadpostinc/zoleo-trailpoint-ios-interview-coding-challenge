//
//  DeviceDetailViewModel.swift
//  TrailPoint
//

import Foundation

@MainActor
@Observable
final class DeviceDetailViewModel {

    private(set) var device: Device
    private(set) var isRefreshing = false
    private(set) var refreshErrorMessage: String?

    private let repository: DeviceRepository

    init(device: Device, repository: DeviceRepository = RemoteDeviceRepository()) {
        self.device = device
        self.repository = repository
    }

    func refreshStatus() async {
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            device = try await repository.fetchStatus(for: device.id)
            refreshErrorMessage = nil
        } catch {
            refreshErrorMessage = "Failed to refresh status."
        }
    }
}
