//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core
import TestsFoundation

class URLSubmissionTests: StudentUITestCase {
    func testSumbitUrl() {
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
        app.find(label: "Done").tap()
        URLSubmission.submit.tap()
        XCTAssertTrue(URLSubmission.loadingView.exists)
        XCTAssertTrue(URLSubmission.loadingView.isVisible)

        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            assignment_id: assignment.id,
            user_id: "1",
            submission_type: .online_url,
            url: URL(string: "http://www.amazon.com")
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.urlButton.waitToExist(5)
        XCTAssertEqual(SubmissionDetails.urlButton.label, "http://www.amazon.com")
    }
}
