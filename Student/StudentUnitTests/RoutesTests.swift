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
        XCTAssert(router.match(Route.group("7").url) is GroupNavigationViewController)
    }

    func testQuizzes() {
        XCTAssert(router.match(Route.quizzes(forCourse: "3").url) is QuizListViewController)
    }

    func testAssignmentList() {
        XCTAssert(router.match(Route.assignments(forCourse: "1").url) is AssignmentListViewController)
    }

    func testCourseNavTab() {
        XCTAssert(router.match(Route.course("1").url) is CourseNavigationViewController)
    }

    func testSubmission() {
        XCTAssert(router.match(Route.submission(forCourse: "1", assignment: "1", user: ":userID").url) is SubmissionDetailsViewController)
    }

    func testAssignmentUrlSubmission() {
        XCTAssert(router.match(Route.assignmentUrlSubmission(courseID: "1", assignmentID: "1", userID: "1").url) is UrlSubmissionViewController)
    }

    func testLogs() {
        XCTAssert(router.match(Route.logs.url) is LogEventListViewController)
    }

    func testActAsUser() {
        XCTAssert(router.match(Route.actAsUser.url) is ActAsUserViewController)
    }

    func testActAsUserID() {
        XCTAssert(router.match(Route.actAsUserID("3").url) is ActAsUserViewController)
    }
}
