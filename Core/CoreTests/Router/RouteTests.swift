//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
@testable import Core

class RouteTests: XCTestCase {
    func testConversations() {
        XCTAssertEqual(Route.conversations.url.path, "/conversations")
        XCTAssertEqual(Route.conversation("5").url.path, "/conversations/5")
        XCTAssertEqual(Route.compose().url.path, "/conversations/compose")
        XCTAssertNil(Route.compose().url.queryItems)
        XCTAssertEqual(Route.compose(body: "b", context: ContextModel(.course, id: "1"), observeeID: "2", recipients: [ .make() ], subject: "s").url.queryItems, [
            URLQueryItem(name: "body", value: "b"),
            URLQueryItem(name: "context", value: "course_1"),
            URLQueryItem(name: "observeeID", value: "2"),
            URLQueryItem(name: "recipients", value: try? JSONEncoder().encode([
                APIConversationRecipient.make(),
            ]).base64EncodedString()),
            URLQueryItem(name: "subject", value: "s"),
        ])
    }

    func testCourse() {
        XCTAssertEqual(Route.course("7").url.path, "/courses/7")
    }

    func testCourseUser() {
        XCTAssertEqual(Route.course("4", user: "5").url.path, "/courses/4/users/5")
    }

    func testCourseAssignments() {
        XCTAssertEqual(Route.assignments(forCourse: "4").url.path, "/courses/4/assignments")
    }

    func testCourseAssignment() {
        XCTAssertEqual(Route.course("4", assignment: "1").url.path, "/courses/4/assignments/1")
    }

    func testGroup() {
        XCTAssertEqual(Route.group("2").url.path, "/groups/2")
    }

    func testQuizzesForCourse() {
        XCTAssertEqual(Route.quizzes(forCourse: "9").url.path, "/courses/9/quizzes")
    }

    func testQuiz() {
        XCTAssertEqual(Route.quiz(forCourse: "3", quizID: "6").url.path, "/courses/3/quizzes/6")
    }

    func testTakeQuiz() {
        XCTAssertEqual(Route.takeQuiz(forCourse: "3", quizID: "6").url.path, "/courses/3/quizzes/6/take")
    }

    func testModules() {
        XCTAssertEqual(Route.modules(forCourse: "9").url.path, "/courses/9/modules")
    }

    func testModule() {
        XCTAssertEqual(Route.module(forCourse: "9", moduleID: "2").url.path, "/courses/9/modules/2")
    }

    func testSendSupport() {
        XCTAssertEqual(Route.errorReport(for: "type").url.path, "/support/type")
    }

    func testTermsOfService() {
        XCTAssertEqual(Route.termsOfService(forAccount: "1").url.path, "/accounts/1/terms_of_service")
    }

    func testActAsUserID() {
        XCTAssertEqual(Route.actAsUserID("2").url.path, "/act-as-user/2")
    }

    func testPeopleListCourse() {
        XCTAssertEqual(Route.people(forCourse: "1").url.path, "/courses/1/users")
    }

    func testPeopleListGroup() {
        XCTAssertEqual(Route.people(forGroup: "1").url.path, "/groups/1/users")
    }
}
