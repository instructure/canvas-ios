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

    func test_logReceiveValue_valueReportedToAnalytics() {
        // GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        publisher.logReceiveValue(
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
        publisher.logReceiveValue(
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
        publisher.logReceiveValue(
            "test event",
            storeIn: &subscriptions
        )

        // WHEN
        publisher.send(completion: .failure(NSError.internalError()))

        // THEN
        XCTAssertEqual(analytics.totalEventCount, 0)
        XCTAssertEqual(analytics.lastEvent, nil)
    }
}
