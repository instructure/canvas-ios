//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
@testable import Parent
import XCTest
@testable import Core

class RoutesTests: ParentTestCase {
    func testRoutes() {
        XCTAssert(Parent.router.match(.parse("/courses/1/grades")) is CourseDetailsViewController)
        XCTAssert(Parent.router.match(.parse("/courses/1/assignments/syllabus")) is SyllabusViewController)
        XCTAssert(Parent.router.match(Route.conversations.url) is ParentConversationListViewController)
        XCTAssert(Parent.router.match(Route.conversation("1").url) is ConversationDetailViewController)
        XCTAssert(Parent.router.match(.parse("/calendar")) is PlannerViewController)
        XCTAssert(Parent.router.match(.parse("/calendar?event_id=1")) is CalendarEventDetailsViewController)
        XCTAssert(Parent.router.match(Route.submission(forCourse: "1", assignment: "1", user: "1").url) is AssignmentDetailsViewController)

        XCTAssert(Parent.router.match(.parse("/files/1")) is FileDetailsViewController)
        XCTAssert(Parent.router.match(.parse("/files/2/download")) is FileDetailsViewController)
        XCTAssert(Parent.router.match(.parse("/courses/1/files/3")) is FileDetailsViewController)
        XCTAssert(Parent.router.match(.parse("/courses/1/files/4/download")) is FileDetailsViewController)
    }
}
