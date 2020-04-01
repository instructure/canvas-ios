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
@testable import Core
@testable import Student
import TestsFoundation

class RoutesTests: XCTestCase {
    class LoginDelegate: Core.LoginDelegate {
        func userDidLogin(session: LoginSession) {
        }

        func userDidLogout(session: LoginSession) {
        }

        var opened: URL?
        var openedExpectation = XCTestExpectation(description: "openedExternalURL")
        func openExternalURL(_ url: URL) {
            openedExpectation.fulfill()
            opened = url
        }
    }

    // swiftlint:disable:next weak_delegate
    let loginDelegate = LoginDelegate()

    override func setUp() {
        super.setUp()
        AppEnvironment.shared.currentSession = LoginSession.make()
        AppEnvironment.shared.loginDelegate = loginDelegate
        AppEnvironment.shared.api = URLSessionAPI(loginSession: nil, baseURL: nil, urlSession: MockURLSession())
    }

    override func tearDown() {
        super.tearDown()
        AppEnvironment.shared.currentSession = nil
    }

    func testActAsUser() {
        XCTAssert(router.match(Route.actAsUser.url) is ActAsUserViewController)
    }

    func testActAsUserID() {
        XCTAssertEqual((router.match(Route.actAsUserID("3").url) as? ActAsUserViewController)?.initialUserID, "3")
    }

    func testCalendar() {
        XCTAssert(router.match(.parse("/calendar")) is PlannerViewController)

        // XCTAssert(router.match(.parse("/calendar?event_id=7")) is CalendarEventDetailViewController)
        XCTAssertNotNil(router.match(.parse("/calendar?event_id=7")))
        AppEnvironment.shared.currentSession = nil
        XCTAssertNil(router.match(.parse("/calendar?event_id=7")))
    }

    func testCalendarEvents() {
        // XCTAssert(router.match(.parse("/calendar_events/7")) is CalendarEventDetailViewController)
        XCTAssertNotNil(router.match(.parse("/calendar_events/7")))
        AppEnvironment.shared.currentSession = nil
        XCTAssertNil(router.match(.parse("/calendar_events/7")))
    }

    func testConversation() {
        XCTAssertEqual((router.match(.parse("/conversations/1")) as? HelmViewController)?.moduleName, "/conversations/:conversationID")
    }

    func testCourses() {
        ExperimentalFeature.nativeDashboard.isEnabled = false
        XCTAssertEqual((router.match(Route.courses.url) as? HelmViewController)?.moduleName, "/courses")
        ExperimentalFeature.nativeDashboard.isEnabled = true
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
        XCTAssert((router.match(Route.assignments(forCourse: "1").url) is AssignmentListViewController))
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

    func testPeopleListCourse() {
        XCTAssert(router.match(Route.people(forCourse: "1").url) is PeopleListViewController)
    }

    func testPeopleListGroup() {
        XCTAssert(router.match(Route.people(forGroup: "1").url) is PeopleListViewController)
    }

    func testModules() {
        ExperimentalFeature.studentModules.isEnabled = false
        XCTAssert(router.match(Route.modules(forCourse: "1").url) is ModulesTableViewController)
        XCTAssert(router.match(Route.module(forCourse: "1", moduleID: "1").url) is ModuleDetailsViewController)
        ExperimentalFeature.studentModules.isEnabled = true
        XCTAssert(router.match(Route.modules(forCourse: "1").url) is ModuleListViewController)
        XCTAssert(router.match(Route.module(forCourse: "1", moduleID: "1").url) is ModuleListViewController)
    }

    func testFallbackNonHTTP() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route")!
        MockURLSession.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected))
        router.route(to: "canvas-courses://canvas.instructure.com/not-a-native-route", from: UIViewController())
        wait(for: [loginDelegate.openedExpectation], timeout: 1)
        XCTAssertEqual(loginDelegate.opened, expected)
    }

    func testFallbackRelative() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route")!
        MockURLSession.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected))
        AppEnvironment.shared.currentSession = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com")!)
        router.route(to: "not-a-native-route", from: UIViewController())
        wait(for: [loginDelegate.openedExpectation], timeout: 1)
        XCTAssertEqual(loginDelegate.opened, expected)
    }

    func testFallbackAbsoluteHTTPs() {
        let expected = URL(string: "https://google.com")!
        MockURLSession.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected))
        router.route(to: "https://google.com", from: UIViewController())
        wait(for: [loginDelegate.openedExpectation], timeout: 1)
        XCTAssertEqual(loginDelegate.opened, expected)
    }

    func testFallbackOpensAuthenticatedSession() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route?token=abcdefg")!
        MockURLSession.mock(
            GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/not-a-native-route")),
            value: .init(session_url: expected)
        )
        router.route(to: "canvas-courses://canvas.instructure.com/not-a-native-route", from: UIViewController())
        wait(for: [loginDelegate.openedExpectation], timeout: 1)
        XCTAssertEqual(loginDelegate.opened, expected)
    }

    func testFallbackAuthenticatedError() {
        let expected = URL(string: "https://google.com")!
        MockURLSession.mock(GetWebSessionRequest(to: expected), error: NSError.internalError())
        router.route(to: "https://google.com", from: UIViewController())
        wait(for: [loginDelegate.openedExpectation], timeout: 1)
        XCTAssertEqual(loginDelegate.opened, expected)
    }
}
