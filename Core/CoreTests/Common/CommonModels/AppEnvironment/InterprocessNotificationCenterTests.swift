//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import Core
import XCTest

class InterprocessNotificationCenterTests: XCTestCase {
    private let testee = InterprocessNotificationCenter.shared
    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testSubscription() {
        // MARK: - GIVEN
        let subscription1Received = expectation(description: "Subscription received value")
        testee
            .subscribe(forName: "test1")
            .sink { subscription1Received.fulfill() }
            .store(in: &subscriptions)

        let subscription2NotReceived = expectation(description: "Subscription not received value")
        subscription2NotReceived.isInverted = true
        testee
            .subscribe(forName: "test2")
            .sink { subscription2NotReceived.fulfill() }
            .store(in: &subscriptions)

        // MARK: - WHEN
        testee.post(name: "test1")

        // MARK: - THEN
        waitForExpectations(timeout: 1)
    }

    func testMultipleSubscriptions() {
        // MARK: - GIVEN
        let subscription1Received = expectation(description: "Subscription received value")
        testee
            .subscribe(forName: "test")
            .sink { subscription1Received.fulfill() }
            .store(in: &subscriptions)

        let subscription2Received = expectation(description: "Subscription received value")
        testee
            .subscribe(forName: "test")
            .sink { subscription2Received.fulfill() }
            .store(in: &subscriptions)

        let singleNotificationReceived = expectation(description: "Notification received")
        testee
            .notifications
            .sink { _ in singleNotificationReceived.fulfill() }
            .store(in: &subscriptions)

        // MARK: - WHEN
        testee.post(name: "test")

        // MARK: - THEN
        waitForExpectations(timeout: 1)
    }

    func testMultipleSubscriptionsWhenOneCancelled() {
        // MARK: - GIVEN
        let subscription1Received = expectation(description: "Subscription received value")
        testee
            .subscribe(forName: "test")
            .sink { subscription1Received.fulfill() }
            .store(in: &subscriptions)

        let subscription2Received = expectation(description: "Subscription received value")
        subscription2Received.isInverted = true
        var secondSubscription: AnyCancellable? = testee
            .subscribe(forName: "test")
            .sink { subscription2Received.fulfill() }

        let singleNotificationReceived = expectation(description: "Notification received")
        testee
            .notifications
            .sink { _ in singleNotificationReceived.fulfill() }
            .store(in: &subscriptions)

        // MARK: - WHEN
        secondSubscription = nil
        testee.post(name: "test")

        // MARK: - THEN
        waitForExpectations(timeout: 1)
        secondSubscription?.cancel()
    }

    func testSubscriptionCancel() {
        // MARK: - GIVEN
        let subscriptionNotReceived = expectation(description: "Subscription not received value")
        subscriptionNotReceived.isInverted = true
        var subscription: AnyCancellable? = testee
            .subscribe(forName: "test")
            .sink { subscriptionNotReceived.fulfill() }

        let noNotificationReceived = expectation(description: "Notification not received")
        noNotificationReceived.isInverted = true
        testee
            .notifications
            .sink { _ in
                noNotificationReceived.fulfill()
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        subscription = nil
        testee.post(name: "test")

        // MARK: - THEN
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription?.cancel()
    }
}
