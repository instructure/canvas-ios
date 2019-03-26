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

class UrlSubmissionPageTests: StudentTest {
    let page = UrlSubmissionPage.self

    func testSumbitUrl() {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        let assignment = APIAssignment.make([ "submission_types": [ "online_url" ] ])
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
        mockData(CreateSubmissionRequest(context: course, assignmentID: assignment.id.value, body: nil), noCallback: true)

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1/urlsubmission")
        page.assertVisible(.url)
        page.assertVisible(.preview)
        page.assertHidden(.loadingView)
        page.typeText("www.amazon.com", in: .url)
        page.tap(label: "Done")
        page.tap(.submit)
        page.assertExists(.loadingView)
        page.assertVisible(.loadingView)

        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "assignment_id": assignment.id.value,
            "user_id": "1",
            "submission_type": "online_url",
            "url": "http://www.amazon.com",
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetailsPage.waitToExist(.urlButton, timeout: 5)
        SubmissionDetailsPage.assertText(.urlButton, equals: "http://www.amazon.com")
    }
}
