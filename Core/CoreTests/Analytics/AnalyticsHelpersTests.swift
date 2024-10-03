//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import Combine
import XCTest

class AnalyticsHelpersTests: CoreTestCase {
    var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - LogReceiveValue

    func test_logReceiveValue_valueReportedToAnalytics() {
        // GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        publisher.logReceiveOutput(
            "test_event",
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(())

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 1)
        XCTAssertEqual(analytics.lastEvent, "test_event")
    }

    func test_logReceiveValue_completionNotReportedToAnalytics() {
        // GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        publisher.logReceiveOutput(
            "test event",
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(completion: .finished)

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 0)
        XCTAssertEqual(analytics.lastEvent, nil)
    }

    func test_logReceiveValue_errorNotReportedToAnalytics() {
        // GIVEN
        let publisher = PassthroughSubject<Void, Error>()
        publisher.logReceiveOutput(
            "test event",
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(completion: .failure(NSError.internalError()))

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 0)
        XCTAssertEqual(analytics.lastEvent, nil)
    }

    // MARK: - LogReceiveValue With Dynamic Name

    func test_logReceiveValueDynamicName_valueReportedToAnalytics() {
        // GIVEN
        let publisher = PassthroughSubject<Int, Never>()
        publisher.logReceiveOutput(
            { value in
                XCTAssertEqual(value, 1)
                return "test_event"
            },
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(1)

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 1)
        XCTAssertEqual(analytics.lastEvent, "test_event")
    }

    func test_logReceiveValueDynamicName_completionNotReportedToAnalytics() {
        // GIVEN
        let nameNotQueried = expectation(description: "Log name not queried")
        nameNotQueried.isInverted = true
        let publisher = PassthroughSubject<Int, Never>()
        publisher.logReceiveOutput(
            { _ in
                nameNotQueried.fulfill()
                return "test event"
            },
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(completion: .finished)

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 0)
        XCTAssertEqual(analytics.lastEvent, nil)
        waitForExpectations(timeout: 1)
    }

    func test_logReceiveValueDynamicName_errorNotReportedToAnalytics() {
        // GIVEN
        let nameNotQueried = expectation(description: "Log name not queried")
        nameNotQueried.isInverted = true
        let publisher = PassthroughSubject<Int, Error>()
        publisher.logReceiveOutput(
            { _ in
                nameNotQueried.fulfill()
                return "test event"
            },
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(completion: .failure(NSError.internalError()))

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 0)
        XCTAssertEqual(analytics.lastEvent, nil)
        waitForExpectations(timeout: 1)
    }
}
