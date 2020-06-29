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
        XCTAssert(router.match("/act-as-user") is ActAsUserViewController)
    }

    func testActAsUserID() {
        XCTAssertEqual((router.match("/act-as-user/3") as? ActAsUserViewController)?.initialUserID, "3")
    }

    func testCalendar() {
        XCTAssert(router.match("/calendar") is PlannerViewController)

        // XCTAssert(router.match("/calendar?event_id=7") is CalendarEventDetailViewController)
        XCTAssertNotNil(router.match("/calendar?event_id=7"))
        AppEnvironment.shared.currentSession = nil
        XCTAssertNil(router.match("/calendar?event_id=7"))
    }

    func testCalendarEvents() {
        // XCTAssert(router.match("/calendar_events/7") is CalendarEventDetailViewController)
        XCTAssertNotNil(router.match("/calendar_events/7"))
        AppEnvironment.shared.currentSession = nil
        XCTAssertNil(router.match("/calendar_events/7"))
    }

    func testConversation() {
        XCTAssertEqual((router.match("/conversations/1") as? HelmViewController)?.moduleName, "/conversations/:conversationID")
    }

    func testCourses() {
        ExperimentalFeature.nativeDashboard.isEnabled = false
        XCTAssertEqual((router.match("/courses") as? HelmViewController)?.moduleName, "/courses")
        ExperimentalFeature.nativeDashboard.isEnabled = true
        XCTAssert(router.match("/courses") is CourseListViewController)
    }

    func testCourseAssignment() {
        XCTAssert(router.match("/courses/2/assignments/3") is ModuleItemSequenceViewController)
    }

    func testGroup() {
        XCTAssert(router.match("/groups/7") is GroupNavigationViewController)
    }

    func testQuizzes() {
        XCTAssert(router.match("/courses/3/quizzes") is QuizListViewController)
    }

    func testAssignmentList() {
        XCTAssert(router.match("/courses/1/assignments") is HelmViewController)
    }

    func testCourseNavTab() {
        XCTAssertEqual((router.match("/courses/1") as? HelmViewController)?.moduleName, "/courses/:courseID")
    }

    func testSubmission() {
        XCTAssert(router.match("/courses/1/assignments/1/submissions/2") is SubmissionDetailsViewController)
    }

    func testLogs() {
        XCTAssert(router.match("/logs") is LogEventListViewController)
    }

    func testPeopleListCourse() {
        XCTAssert(router.match("/courses/1/users") is PeopleListViewController)
    }

    func testPeopleListGroup() {
        XCTAssert(router.match("/groups/1/users") is PeopleListViewController)
    }

    func testModules() {
        XCTAssert(router.match("/courses/1/modules") is ModuleListViewController)
        XCTAssert(router.match("/courses/1/modules/1") is ModuleListViewController)
    }

    func testModuleItems() {
        XCTAssert(router.match("/courses/1/assignments/syllabus") is StudentSyllabusViewController)
        XCTAssert(router.match("/courses/1/assignments/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/assignments/2?origin=module_item_details") is AssignmentDetailsViewController)
        XCTAssert(router.match("/courses/1/discussions/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/discussions/2") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/1/discussion_topics/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/discussion_topics/2") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/1/discussion_topics/2?origin=module_item_details") is DiscussionDetailsViewController)
        XCTAssert(router.match("/files/1") is FileDetailsViewController)
        XCTAssert(router.match("/files/1/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2/download") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/files/2/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2/download?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2?origin=module_item_details") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/quizzes/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/module_item_redirect/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/modules/2/items/3") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/modules/items/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/pages/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/pages/2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/wiki/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/wiki/2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/pages/2?origin=module_item_details") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/wiki/2?origin=module_item_details") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/quizzes/2?origin=module_item_details") is QuizIntroViewController)
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
        XCTAssertEqual(loginDelegate.opened?.absoluteURL, expected)
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
