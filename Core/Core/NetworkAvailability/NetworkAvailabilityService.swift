//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Combine
import Foundation
import Network

public protocol NetworkAvailabilityService {
    func startMonitoring()
    func stopMonitoring()

    func startObservingStatus() -> CurrentValueSubject<NetworkAvailabilityStatus, Never>
    var status: NetworkAvailabilityStatus { get }
}

public final class NetworkAvailabilityServiceLive: NetworkAvailabilityService {
    // MARK: - Dependencies

    private let monitor: NWPathMonitorWrapper

    // MARK: - Properties

    public private(set) var status: NetworkAvailabilityStatus = .disconnected {
        didSet {
            statusSubject.send(status)
        }
    }

    private let statusSubject = CurrentValueSubject<NetworkAvailabilityStatus, Never>(.disconnected)
    private var isMonitoring = false
    private let queue = DispatchQueue(label: "\(Bundle.main.appBundleIdentifier).network-availability")

    /// The `NetworkAvailabiltyService` component monitors network conditions and reports updates whenever there's a change.
    /// - Parameter monitor: When instantiating an `NWPathMonitorWrapper` use a unique `NWPathMonitor` instance. Using a shared instance will cause problems with starting, stopping and observing the changes.
    public init(monitor: NWPathMonitorWrapper = NWPathMonitorWrapper(from: NWPathMonitor())) {
        assert(
            monitor.updateHandler == nil,
            "Using a shared NWPathMonitor instance is forbidden. Please use a unique instance instead."
        )
        self.monitor = monitor
        self.monitor.updateHandler = { [weak self] path in
            self?.updateStatus(path)
        }
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }
        monitor.start(queue)
        isMonitoring = true
    }

    private func updateStatus(_ path: NWPathWrapper) {
        switch path.status {
        case .satisfied:
            if path.isExpensive {
                status = .connected(.cellular)
            } else {
                status = .connected(.wifi)
            }
        case .unsatisfied, .requiresConnection:
            status = .disconnected
        @unknown default:
            break
        }
    }

    public func stopMonitoring() {
        isMonitoring = false
        monitor.cancel()
    }

    public func startObservingStatus() -> CurrentValueSubject<NetworkAvailabilityStatus, Never> {
        statusSubject
    }
}
