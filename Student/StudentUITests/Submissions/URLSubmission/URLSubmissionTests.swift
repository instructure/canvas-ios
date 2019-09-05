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

class URLSubmissionTests: StudentUITestCase {
    func xtestSumbitUrl() {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        let assignment = APIAssignment.make(submission_types: [ .online_url ])
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
        mockData(CreateSubmissionRequest(context: course, assignmentID: assignment.id.value, body: nil), noCallback: true)

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1/urlsubmission")
        XCTAssertTrue(URLSubmission.url.isVisible)
        XCTAssertTrue(URLSubmission.url.isVisible)
        XCTAssertTrue(URLSubmission.preview.isVisible)
        XCTAssertFalse(URLSubmission.loadingView.isVisible)
        URLSubmission.url.tap()
        URLSubmission.url.typeText("www.amazon.com")
        URLSubmission.submit.tap()
        XCTAssertTrue(URLSubmission.loadingView.exists)
        XCTAssertTrue(URLSubmission.loadingView.isVisible)
    }

    func xtestShowSubmission() {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        let assignment = APIAssignment.make(submission_types: [ .online_url ])
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            assignment_id: assignment.id,
            user_id: "1",
            submission_type: .online_url,
            url: URL(string: "http://www.amazon.com")
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.urlButton.waitToExist()
        XCTAssertEqual(SubmissionDetails.urlButton.label, "http://www.amazon.com")
    }
}
