//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class HelpLinkRouteTests: CoreTestCase {

    func testNormalLink() {
        let testee = HelpLink(context: databaseClient)
        testee.id = "nonSpecialID"
        testee.url = URL(string: "https://instructure.com")!

        let result = testee.route
        XCTAssertEqual(result?.path, "https://instructure.com")
        XCTAssertEqual(result?.options, .modal(embedInNav: true))
    }

    func testInstructorQuestionLink() {
        let testee = HelpLink(context: databaseClient)
        testee.id = "instructor_question"

        let result = testee.route
        XCTAssertEqual(result?.path, "/conversations/compose?autoTeacherSelect=true&recipientsDisabled=true&alwaysShowRecipients=true")
        XCTAssertEqual(result?.options, .modal(.formSheet, embedInNav: true))
    }

    func testReportProblemLink() {
        let testee = HelpLink(context: databaseClient)
        testee.id = "report_a_problem"

        let result = testee.route
        XCTAssertEqual(result?.path, "/support/problem")
        XCTAssertEqual(result?.options, .modal(.formSheet, embedInNav: true))
    }
}
