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

@testable import Core
import XCTest
import TestsFoundation

class DashboardCardsViewModelTests: CoreTestCase {

    func testFetchesDashboardCards() {
        api.mock(GetCourses(enrollmentState: nil), value: [
            .make(id: 1),
            .make(id: 2),
        ])
        api.mock(GetDashboardCards(), value: [
            .make(id: 1, shortName: "card 1"),
            .make(id: 2, shortName: "card 2"),
        ])

        let testee = DashboardCardsViewModel(showOnlyTeacherEnrollment: false)

        let uiRefreshExpectation = expectation(description: "ui refresh received")
        uiRefreshExpectation.expectedFulfillmentCount = 2 // initial loading state, data state
        let refreshCallbackExpectation = expectation(description: "refresh callback called")
        let subscription = testee.$state.sink { _ in uiRefreshExpectation.fulfill() }
        testee.refresh { refreshCallbackExpectation.fulfill() }
        drainMainQueue()

        wait(for: [uiRefreshExpectation, refreshCallbackExpectation], timeout: 0.1)

        guard case .data(let cards) = testee.state else { XCTFail("No data in view model"); return }

        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards[0].id, "1")
        XCTAssertEqual(cards[0].shortName, "card 1")
        XCTAssertEqual(cards[1].id, "2")
        XCTAssertEqual(cards[1].shortName, "card 2")

        subscription.cancel()
    }

    func testLayoutSelectionFlagOnEmptyCourses() {
        let testee = DashboardCardsViewModel(showOnlyTeacherEnrollment: false)
        XCTAssertFalse(testee.shouldShowSettingsButton)

        testee.refresh()
        drainMainQueue()

        guard case .empty = testee.state else { XCTFail("View model should be empty"); return }

        XCTAssertFalse(testee.shouldShowSettingsButton)
    }

    func testLayoutSelectionFlagWhenCoursesAvailable() {
        api.mock(GetCourses(enrollmentState: nil), value: [.make(id: 1)])
        api.mock(GetDashboardCards(), value: [.make(id: 1, shortName: "card 1")])

        let testee = DashboardCardsViewModel(showOnlyTeacherEnrollment: false)
        XCTAssertFalse(testee.shouldShowSettingsButton)

        testee.refresh()
        drainMainQueue()

        guard case .data = testee.state else { XCTFail("No data in view model"); return }

        XCTAssertTrue(testee.shouldShowSettingsButton)
    }
}
