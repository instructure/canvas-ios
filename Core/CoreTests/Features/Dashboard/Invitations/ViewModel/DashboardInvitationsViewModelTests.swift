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

    func testFetching() {
        setupMocks()

        // Initial loading
        let testee = DashboardInvitationsViewModel()
        drainMainQueue(thoroughness: 5)

        XCTAssertEqual(testee.items.count, 1)

        if let invitation = testee.items.first {
            XCTAssertEqual(invitation.id, "enrollmentId")
            XCTAssertEqual(invitation.name, "test course, Section One")
        } else {
            XCTFail("Invitation not found")
        }

        // Given enrollments changed on BE, including more invitations
        API.resetMocks()
        setupMocks(invitationsCount: 3)

        // When refresh is requested
        testee.refresh()
        drainMainQueue(thoroughness: 5)

        // Then
        XCTAssertEqual(testee.items.count, 3)

        testee.items.enumerated().forEach { (offset, invitation) in
            let expectedID = "enrollmentId" + (offset > 0 ?  "-\(offset)" : "")
            XCTAssertEqual(invitation.id, expectedID)
            XCTAssertEqual(invitation.name, "test course, Section One")
        }
    }

    func testItemDismissRemovesItFromItemsArray() {
        setupMocks()

        let testee = DashboardInvitationsViewModel()
        drainMainQueue(thoroughness: 5)

        guard let invitation = testee.items.first else {
            XCTFail("Invitation not found")
            return
        }

        invitation.accept()
        XCTAssertEqual(testee.items.count, 1)
        waitUntil(shouldFail: true) {
            testee.items.count == 0
        }
    }

    // MARK: Helpers

    private func setupMocks(invitationsCount: Int = 1) {
        setupInvitationMocks(count: invitationsCount)

        let coursesRequest = GetCoursesRequest(enrollmentState: .invited_or_pending, perPage: 100)
        api.mock(coursesRequest, value: [.make(id: "courseId", name: "test course", sections: [.init(end_at: nil, id: "sectionId", name: "Section One", start_at: nil)])])
    }

    private func setupInvitationMocks(count: Int) {
        let enrollmentsRequest = GetEnrollmentsRequest(
            context: .currentUser,
            states: [.invited, .current_and_future]
        )

        let mockEnrollments = (0 ..< count).map { i in
            APIEnrollment
                .make(
                    id: "enrollmentId\(i > 0 ? "-\(i)" : "")",
                    course_id: "courseId",
                    course_section_id: "sectionId",
                    enrollment_state: .invited
                )
        }

        api.mock(enrollmentsRequest, value: mockEnrollments)
    }
}
