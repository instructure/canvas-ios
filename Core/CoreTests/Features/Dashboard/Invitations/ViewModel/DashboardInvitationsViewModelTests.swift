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

class DashboardInvitationsViewModelTests: CoreTestCase {

    func testFetch() {
        setupMocks()
        let testee = DashboardInvitationsViewModel()
        let viewModelUpdatedExpectation = expectation(description: "view model updated")
        let updateSubscription = testee.objectWillChange.sink {
            viewModelUpdatedExpectation.fulfill()
        }

        testee.refresh()

        wait(for: [viewModelUpdatedExpectation], timeout: 1)
        XCTAssertEqual(testee.items.count, 1)
        guard let invitation = testee.items.first else { return }

        XCTAssertEqual(invitation.id, "enrollmentId")
        XCTAssertEqual(invitation.name, "test course, Section One")

        updateSubscription.cancel()
    }

    func testItemDismissRemovesItFromItemsArray() {
        setupMocks()
        let testee = DashboardInvitationsViewModel()
        testee.refresh()
        guard let invitation = testee.items.first else { XCTFail("Invitation not found"); return }

        invitation.accept()
        XCTAssertEqual(testee.items.count, 1)
        waitUntil(shouldFail: true) {
            testee.items.count == 0
        }
    }

    private func setupMocks() {
        let enrollmentsRequest = GetEnrollmentsRequest(context: .currentUser, states: [.invited, .current_and_future])
        api.mock(enrollmentsRequest, value: [.make(id: "enrollmentId", course_id: "courseId", course_section_id: "sectionId", enrollment_state: .invited)])

        let coursesRequest = GetCoursesRequest(enrollmentState: .invited_or_pending, perPage: 100)
        api.mock(coursesRequest, value: [.make(id: "courseId", name: "test course", sections: [.init(end_at: nil, id: "sectionId", name: "Section One", start_at: nil)])])
    }
}
