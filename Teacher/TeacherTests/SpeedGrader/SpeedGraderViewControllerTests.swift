//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI
import Combine
@testable import Core
@testable import Teacher
import TestsFoundation

class SpeedGraderViewControllerTests: TeacherTestCase {
    lazy var controller = SpeedGraderViewController(context: .course("1"), assignmentID: "1", userID: "1", filter: [])

    override func setUp() {
        super.setUp()
        api.mock(GetAssignment(courseID: "1", assignmentID: "1", include: [ .overrides ]), value: .make())
        api.mock(GetSubmissions(context: .course("1"), assignmentID: "1"), value: [
            .make(submission_history: [], user: .make(avatar_url: URL(string: "data:text/plain,")))
        ])
    }

    func testLayout() throws {
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(controller.pages.parent)
        XCTAssertNil(controller.emptyView.parent)
    }

    func testEmpty() throws {
        controller = SpeedGraderViewController(context: .course("1"), assignmentID: "1", userID: "bogus", filter: [])
        controller.view.layoutIfNeeded()
        XCTAssertNil(controller.pages.parent)
        XCTAssertNotNil(controller.emptyView.parent)
    }

    func testHidesInactiveStudentSubmissions() {
        api.mock(GetAssignment(courseID: "1", assignmentID: "1", include: [ .overrides ]), value: .make())
        api.mock(GetSubmissions(context: .course("1"), assignmentID: "1"), value: [
            .make(id: "1", submission_history: [], submission_type: .online_upload, user_id: "1"),
            .make(id: "2", submission_history: [], submission_type: .online_upload, user_id: "2")
        ])
        // User2 should be inactive
        api.mock(GetEnrollments(context: .course("1")), value: [
            .make(id: "1", course_id: "1", enrollment_state: .active, user_id: "1"),
            .make(id: "2", course_id: "1", enrollment_state: .inactive, user_id: "2")
        ])
        controller = SpeedGraderViewController(context: .course("1"), assignmentID: "1", userID: "1", filter: [.needsGrading])

        // WHEN
        controller.view.layoutIfNeeded()

        // THEN
        XCTAssertEqual(controller.submissions.all.count, 1)
    }
}
