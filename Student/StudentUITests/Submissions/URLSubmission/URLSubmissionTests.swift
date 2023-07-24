//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
@testable import Core
import TestsFoundation
import XCTest

class URLSubmissionTests: CoreUITestCase {
    lazy var course = mock(course: .make())
    lazy var assignment = mock(assignment: .make(submission_types: [ .online_url ]))

    func testSubmitUrl() throws {
        try XCTSkipIf(true, "Fails a lot on CI")
        mockBaseRequests()
        mockData(CreateSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, body: nil), noCallback: true)

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        XCTAssertTrue(URLSubmission.url.waitToExist().isVisible)
        XCTAssertTrue(URLSubmission.preview.isVisible)
        XCTAssertFalse(URLSubmission.loadingView.isVisible)
        URLSubmission.url.tap()
        URLSubmission.url.typeText("www.amazon.com")
        URLSubmission.submit.tap()
        XCTAssertTrue(URLSubmission.loadingView.waitToExist().isVisible)
    }

    func testShowSubmission() {
        mockBaseRequests()
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            assignment_id: assignment.id.value,
            submission_type: .online_url,
            url: URL(string: "http://www.amazon.com"),
            user_id: "1"
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()
        XCTAssertEqual(SubmissionDetails.urlButton.label(), "http://www.amazon.com")
    }
}
