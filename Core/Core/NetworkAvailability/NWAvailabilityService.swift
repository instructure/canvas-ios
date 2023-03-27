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

public protocol NWAvailabilityService {
    func startMonitoring()
    func stopMonitoring()

    func startObservingStatus() -> CurrentValueSubject<NWAvailabilityStatus, Never>
    var status: NWAvailabilityStatus { get }
}

public final class NWAvailabilityServiceLive: NWAvailabilityService {
    // MARK: - Depepdencies

    private let monitor: NWPathMonitorWrapper

    // MARK: - Properties

    public private(set) var status: NWAvailabilityStatus = .disconnected {
        didSet {
            statusSubject.send(status)
        }
    }

    private let statusSubject = CurrentValueSubject<NWAvailabilityStatus, Never>(.disconnected)
    private var isMonitoring = false
    private let queue = DispatchQueue(label: "com.instructure.icanvas.network-availability")

    public init(monitor: NWPathMonitorWrapper = NWPathMonitorWrapper(from: NWPathMonitor())) {
        self.monitor = monitor
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }

        monitor.updateHandler = { path in
            self.updateStatus(path)
        }

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

    public func startObservingStatus() -> CurrentValueSubject<NWAvailabilityStatus, Never> {
        statusSubject
    }
}
