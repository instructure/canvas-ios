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
        Course.save(.make(id: "testCourseID", name: "testCourseName"), in: databaseClient)
        api.mock(GetCourseInvitations(), value: [.make(id: "testEnrollmentID", course_id: "testCourseID")])

        let testee = DashboardInvitationsViewModel()
        let viewModelUpdatedExpectation = expectation(description: "view model updated")
        let updateSubscription = testee.objectWillChange.sink {
            viewModelUpdatedExpectation.fulfill()
        }
        testee.refresh()

        wait(for: [viewModelUpdatedExpectation], timeout: 1)
        XCTAssertEqual(testee.invitations.count, 1)
        guard let invitation = testee.invitations.first else { return }

        XCTAssertEqual(invitation.id, "testEnrollmentID")
        XCTAssertEqual(invitation.enrollment.id, "testEnrollmentID")
        XCTAssertEqual(invitation.course.id, "testCourseID")
        XCTAssertEqual(invitation.course.name, "testCourseName")

        updateSubscription.cancel()
    }
}
