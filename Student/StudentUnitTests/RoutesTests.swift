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
@testable import CanvasCore
@testable import CanvasKit
@testable import Core
@testable import TechDebt
@testable import Student
import TestsFoundation

class RoutesTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let user = CKIUser(id: "1")!
        user.name = "Bob"
        CKIClient.current = CKIClient(baseURL: URL(string: "https://canvas.instructure.com")!, token: "t", refreshToken: nil, clientID: nil, clientSecret: nil)
        CKIClient.current?.setValue(user, forKey: "currentUser")
    }

    override func tearDown() {
        super.tearDown()
        CKIClient.current = nil
    }

    func testActAsUser() {
        XCTAssert(router.match(Route.actAsUser.url) is ActAsUserViewController)
    }

    func testActAsUserID() {
        XCTAssertEqual((router.match(Route.actAsUserID("3").url) as? ActAsUserViewController)?.initialUserID, "3")
    }

    func testCalendarEvents() {
        // XCTAssert(router.match(.parse("/calendar_events/7")) is CalendarEventDetailViewController)
        XCTAssertNotNil(router.match(.parse("/calendar_events/7")))
        CKIClient.current = nil
        XCTAssertNil(router.match(.parse("/calendar_events/7")))
    }

    func testConversation() {
        XCTAssertEqual((router.match(.parse("/conversations/1")) as? HelmViewController)?.moduleName, "/conversations/:conversationID")
    }

    func testCourses() {
        XCTAssertEqual((router.match(Route.courses.url) as? HelmViewController)?.moduleName, "/courses")
    }

    func testCourseAssignment() {
        XCTAssert(router.match(Route.course("2", assignment: "3").url) is AssignmentDetailsViewController)
    }

    func testGroup() {
        XCTAssert(router.match(Route.group("7").url) is TabsTableViewController)
        CKIClient.current = nil
        XCTAssertNil(router.match(Route.group("7").url))
    }

    func testQuizzes() {
        XCTAssert(router.match(Route.quizzes(forCourse: "3").url) is QuizListViewController)
    }

    func testAssignmentList() {
        XCTAssertEqual((router.match(Route.assignments(forCourse: "1").url) as? HelmViewController)?.moduleName, "/courses/:courseID/assignments")
    }

    func testCourseNavTab() {
        XCTAssertEqual((router.match(Route.course("1").url) as? HelmViewController)?.moduleName, "/courses/:courseID")
    }

    func testSubmission() {
        XCTAssert(router.match(Route.submission(forCourse: "1", assignment: "1", user: ":userID").url) is SubmissionDetailsViewController)
    }

    func testLogs() {
        XCTAssert(router.match(Route.logs.url) is LogEventListViewController)
    }
}
