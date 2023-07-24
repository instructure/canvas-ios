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

import Foundation
import Network
import XCTest
import Combine

@testable import Core

class NetworkAvailabilityServiceTests: CoreTestCase {
    var service: NetworkAvailabilityService!
    var monitor: NWPathMonitorWrapper!
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        monitor = NWPathMonitorWrapper(start: { _ in () }, cancel: {})
        service = NetworkAvailabilityServiceLive(monitor: monitor)
    }

    override func tearDown() {
        super.tearDown()
        service = nil
        monitor = nil
        for subscription in subscriptions {
            subscription.cancel()
        }
    }

    func testCellularConnectionState() {
        let status = NetworkAvailabilityStatus.connected(.cellular)
        XCTAssertTrue(status.isConnected)
        XCTAssertFalse(status.isConnectedViaWifi)
    }

    func testWifiConnectionState() {
        let status = NetworkAvailabilityStatus.connected(.wifi)
        XCTAssertTrue(status.isConnected)
        XCTAssertTrue(status.isConnectedViaWifi)
    }

    func testNoConnectionState() {
        let status = NetworkAvailabilityStatus.disconnected
        XCTAssertFalse(status.isConnected)
        XCTAssertFalse(status.isConnectedViaWifi)
    }

    func testMonitoringIsInProgressConnectionChangesToNoConnectionStatusUpdates() {
        // Given
        service.startMonitoring()

        // When
        monitor.updateHandler?(
            NWPathWrapper(
                status: .unsatisfied,
                isExpensive: true
            )
        )

        // Then
        XCTAssertEqual(service.status, .disconnected)
    }

    func testMonitoringIsInProgressConnectionChangesToWifiStatusUpdates() {
        // Given
        service.startMonitoring()

        // When
        monitor.updateHandler?(
            NWPathWrapper(
                status: .satisfied,
                isExpensive: false
            )
        )

        // Then
        XCTAssertEqual(service.status, .connected(.wifi))
    }

    func testMonitoringIsInProgressConnectionChangesToCellularStatusUpdates() {
        // Given
        service.startMonitoring()

        // When
        monitor.updateHandler?(
            NWPathWrapper(
                status: .satisfied,
                isExpensive: true
            )
        )

        // Then
        XCTAssertEqual(service.status, .connected(.cellular))
    }

    func testMonitoringIsInProgressConnectionChangesToCellularObservableStatusUpdates() {
        // Given
        service.startMonitoring()
        let expectation = expectation(description: "Publisher receives value")
        expectation.expectedFulfillmentCount = 2
        var status: NetworkAvailabilityStatus!

        service.startObservingStatus()
            .sink { newStatus in
                status = newStatus
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        // When

        monitor.updateHandler?(
            NWPathWrapper(
                status: .satisfied,
                isExpensive: true
            )
        )

        // Then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(service.status, .connected(.cellular))
        XCTAssertEqual(status, .connected(.cellular))
    }
}
