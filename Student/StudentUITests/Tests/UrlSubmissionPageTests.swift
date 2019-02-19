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

    lazy var course: APICourse = {
        return seedClient.createCourse()
    }()
    lazy var teacher: AuthUser = {
        return createTeacher(in: course)
    }()
    lazy var student: AuthUser = {
        return createStudent(in: course)
    }()

    func testSumbitUrl() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_url])
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)/urlsubmission", as: student)
        page.assertVisible(.url)
        page.assertVisible(.preview)
        page.assertHidden(.loadingView)
        page.typeText("www.amazon.com", in: .url)
        page.tap(label: "Done")
        page.tap(.submit)
        page.assertExists(.loadingView)
        page.assertVisible(.loadingView)

        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)
        let submission = SubmissionDetailsPage.self
        submission.assertExists(.urlButton)
        submission.assertText(.urlButton, equals: "http://www.amazon.com")
    }
}
