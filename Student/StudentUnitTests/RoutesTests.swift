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
        ExperimentalFeature.studentModules.isEnabled = false
        XCTAssert(router.match(Route.course("2", assignment: "3").url) is AssignmentDetailsViewController)
        ExperimentalFeature.studentModules.isEnabled = true
        XCTAssert(router.match(Route.course("2", assignment: "3").url) is ModuleItemSequenceViewController)
    }

    func testGroup() {
        XCTAssert(router.match(Route.group("7").url) is GroupNavigationViewController)
    }

    func testQuizzes() {
        XCTAssert(router.match(Route.quizzes(forCourse: "3").url) is QuizListViewController)
    }

    func testAssignmentList() {
        XCTAssert((router.match(Route.assignments(forCourse: "1").url)) is HelmViewController)
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

    func testModuleItems() {
        ExperimentalFeature.studentModules.isEnabled = false
        XCTAssert(router.match(.parse("/courses/1/assignments/syllabus")) is StudentSyllabusViewController)
        XCTAssert(router.match(.parse("/courses/1/assignments/2")) is AssignmentDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/assignments/2?module_item_id=3")) is ModuleItemDetailViewController)
        XCTAssert(router.match(.parse("/courses/1/discussions/2")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/groups/1/discussions/2")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/discussion_topics/2")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/groups/1/discussion_topics/2")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/files/1")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/files/1/download")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/files/1/old")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2/download")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/groups/1/files/2/download")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2?module_item_id=2")) is ModuleItemDetailViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2/download?module_item_id=2")) is ModuleItemDetailViewController)
        XCTAssertNil(router.match(.parse("/courses/1/module_item_redirect/2")))
        XCTAssert(router.match(.parse("/courses/1/modules/2/items/3")) is ModuleItemDetailViewController)
        XCTAssert(router.match(.parse("/courses/1/modules/items/2")) is ModuleItemDetailViewController)
        XCTAssert(router.match(.parse("/courses/1/pages/2")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/groups/1/pages/2")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/wiki/2")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/groups/1/wiki/2")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/pages/2?module_item_id=3")) is ModuleItemDetailViewController)
        XCTAssert(router.match(.parse("/courses/1/wiki/2?module_item_id=3")) is ModuleItemDetailViewController)
        XCTAssert(router.match(.parse("/courses/1/quizzes/2")) is QuizIntroViewController)
        XCTAssert(router.match(.parse("/courses/1/quizzes/2?module_item_id=3")) is ModuleItemDetailViewController)
    }

    func testNewModuleItems() {
        ExperimentalFeature.studentModules.isEnabled = true
        XCTAssert(router.match(.parse("/courses/1/assignments/syllabus")) is StudentSyllabusViewController)
        XCTAssert(router.match(.parse("/courses/1/assignments/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/assignments/2?origin=module_item_details")) is AssignmentDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/discussions/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/groups/1/discussions/2")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/discussion_topics/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/groups/1/discussion_topics/2")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/discussion_topics/2?origin=module_item_details")) is DiscussionDetailsViewController)
        XCTAssert(router.match(.parse("/files/1")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/files/1/download")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/files/1/old")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2/download")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/groups/1/files/2/download")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2?module_item_id=2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2/download?module_item_id=2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/files/2?origin=module_item_details")) is FileDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/quizzes/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/module_item_redirect/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/modules/2/items/3")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/modules/items/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/courses/1/pages/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/groups/1/pages/2")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/wiki/2")) is ModuleItemSequenceViewController)
        XCTAssert(router.match(.parse("/groups/1/wiki/2")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/pages/2?origin=module_item_details")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/wiki/2?origin=module_item_details")) is PageDetailsViewController)
        XCTAssert(router.match(.parse("/courses/1/quizzes/2?origin=module_item_details")) is QuizIntroViewController)
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
