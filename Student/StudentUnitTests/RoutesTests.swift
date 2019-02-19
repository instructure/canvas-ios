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

import XCTest
import Core
@testable import Student
import TestsFoundation

class RoutesTests: XCTestCase {
    func testLogin() {
        XCTAssert(router.match(Route.login.url) is LoginNavigationController)
    }

    func testCourses() {
        XCTAssert(router.match(Route.courses.url) is CourseListViewController)
    }

    func testCourseAssignment() {
        XCTAssert(router.match(Route.course("2", assignment: "3").url) is AssignmentDetailsViewController)
    }

    func testGroup() {
        XCTAssert(router.match(Route.group("7").url) is GroupNavigationTableViewController)
    }

    func testQuizzes() {
        XCTAssert(router.match(Route.quizzes(forCourse: "3").url) is QuizListViewController)
    }

    func testAssignmentList() {
        XCTAssert(router.match(Route.assignments(forCourse: "1").url) is AssignmentListViewController)
    }

    func testCourseNavTab() {
        XCTAssert(router.match(Route.course("1").url) is CourseNavigationTableViewController)
    }

    func testSubmission() {
        XCTAssert(router.match(Route.submission(forCourse: "1", assignment: "1", user: ":userID").url) is SubmissionDetailsViewController)
    }

    func testAssignmentFileUpload() {
        Keychain.currentSession = nil
        XCTAssertNil(router.match(Route.assignmentFileUpload(courseID: "1", assignmentID: "1").url))
        Keychain.currentSession = KeychainEntry.make()
        XCTAssert(router.match(Route.assignmentFileUpload(courseID: "1", assignmentID: "1").url) is FilePickerViewController)
    }

    func testAssignmentUrlSubmission() {
        XCTAssert(router.match(Route.assignmentUrlSubmission(courseID: "1", assignmentID: "1", userID: "1").url) is UrlSubmissionViewController)
    }

    func testLogs() {
        XCTAssert(router.match(Route.logs.url) is LogEventListViewController)
    }
}
