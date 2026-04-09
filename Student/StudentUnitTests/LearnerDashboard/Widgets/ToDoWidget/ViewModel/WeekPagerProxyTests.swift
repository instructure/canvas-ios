//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Student
import XCTest

final class WeekPagerProxyTests: XCTestCase {

    private let testee = WeekPagerProxy()
    private var previousWeekCount = 0
    private var nextWeekCount = 0
    private var todayCount = 0

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - scrollToPreviousWeek

    func test_scrollToPreviousWeek_shouldSendOnPreviousWeekSubject() {
        testee.scrollToPreviousWeekSubject
            .sink { self.previousWeekCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToPreviousWeek()

        XCTAssertEqual(previousWeekCount, 1)
    }

    func test_scrollToPreviousWeek_shouldNotSendOnOtherSubjects() {
        testee.scrollToNextWeekSubject
            .sink { self.nextWeekCount += 1 }
            .store(in: &subscriptions)
        testee.scrollToTodaySubject
            .sink { self.todayCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToPreviousWeek()

        XCTAssertEqual(nextWeekCount, 0)
        XCTAssertEqual(todayCount, 0)
    }

    // MARK: - scrollToNextWeek

    func test_scrollToNextWeek_shouldSendOnNextWeekSubject() {
        testee.scrollToNextWeekSubject
            .sink { self.nextWeekCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToNextWeek()

        XCTAssertEqual(nextWeekCount, 1)
    }

    func test_scrollToNextWeek_shouldNotSendOnOtherSubjects() {
        testee.scrollToPreviousWeekSubject
            .sink { self.previousWeekCount += 1 }
            .store(in: &subscriptions)
        testee.scrollToTodaySubject
            .sink { self.todayCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToNextWeek()

        XCTAssertEqual(previousWeekCount, 0)
        XCTAssertEqual(todayCount, 0)
    }

    // MARK: - scrollToToday

    func test_scrollToToday_shouldSendOnTodaySubject() {
        testee.scrollToTodaySubject
            .sink { self.todayCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToToday()

        XCTAssertEqual(todayCount, 1)
    }

    func test_scrollToToday_shouldNotSendOnOtherSubjects() {
        testee.scrollToPreviousWeekSubject
            .sink { self.previousWeekCount += 1 }
            .store(in: &subscriptions)
        testee.scrollToNextWeekSubject
            .sink { self.nextWeekCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToToday()

        XCTAssertEqual(previousWeekCount, 0)
        XCTAssertEqual(nextWeekCount, 0)
    }

    // MARK: - Multiple calls

    func test_multipleCalls_shouldSendOncePerCall() {
        testee.scrollToPreviousWeekSubject
            .sink { self.previousWeekCount += 1 }
            .store(in: &subscriptions)
        testee.scrollToNextWeekSubject
            .sink { self.nextWeekCount += 1 }
            .store(in: &subscriptions)
        testee.scrollToTodaySubject
            .sink { self.todayCount += 1 }
            .store(in: &subscriptions)

        testee.scrollToPreviousWeek()
        testee.scrollToPreviousWeek()
        testee.scrollToNextWeek()
        testee.scrollToToday()
        testee.scrollToToday()
        testee.scrollToToday()

        XCTAssertEqual(previousWeekCount, 2)
        XCTAssertEqual(nextWeekCount, 1)
        XCTAssertEqual(todayCount, 3)
    }
}
