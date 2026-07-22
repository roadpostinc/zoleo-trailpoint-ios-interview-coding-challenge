//
//  DeviceListViewModel.swift
//  TrailPoint
//

import Foundation

@MainActor
@Observable
final class DeviceListViewModel {

    private(set) var devices: [Device] = []
    private(set) var isLoading = false

    private let repository: DeviceRepository

    init(repository: DeviceRepository = RemoteDeviceRepository()) {
        self.repository = repository
    }

    func loadDevices() async {
        isLoading = true
        defer { isLoading = false }
        devices = (try? await repository.getDevices()) ?? []
    }
}
