//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class DashboardConferencesViewModelTests: CoreTestCase {

    func testCourseConference() {
        api.mock(GetCourses(enrollmentState: nil), value: [.make(id: "testCourseID", name: "testCourseName")])
        api.mock(GetLiveConferences(), value: .init(conferences: [.make(context_id: ID("testCourseID"), context_type: "course", started_at: Clock.now.addMinutes(-60), title: "testConferenceName")]))

        let testee = DashboardConferencesViewModel()
        let viewModelUpdatedExpectation = expectation(description: "view model updated")
        let updateSubscription = testee.objectWillChange.sink {
            viewModelUpdatedExpectation.fulfill()
        }
        testee.refresh()

        wait(for: [viewModelUpdatedExpectation], timeout: 1)
        XCTAssertEqual(testee.conferences.count, 1)
        guard let conference = testee.conferences.first else { return }
        XCTAssertEqual(conference.contextName, "testCourseName")
        XCTAssertEqual(conference.entity.title, "testConferenceName")

        updateSubscription.cancel()
    }

    func testGroupConference() {
        api.mock(GetDashboardGroups(), value: [.make(id: "testGroupID", name: "testGroupName")])
        api.mock(GetLiveConferences(), value: .init(conferences: [.make(context_id: ID("testGroupID"), context_type: "group", started_at: Clock.now.addMinutes(-60), title: "testConferenceName")]))

        let testee = DashboardConferencesViewModel()
        let viewModelUpdatedExpectation = expectation(description: "view model updated")
        let updateSubscription = testee.objectWillChange.sink {
            viewModelUpdatedExpectation.fulfill()
        }
        testee.refresh()

        wait(for: [viewModelUpdatedExpectation], timeout: 1)
        XCTAssertEqual(testee.conferences.count, 1)
        guard let conference = testee.conferences.first else { return }
        XCTAssertEqual(conference.contextName, "testGroupName")
        XCTAssertEqual(conference.entity.title, "testConferenceName")

        updateSubscription.cancel()
    }
}
