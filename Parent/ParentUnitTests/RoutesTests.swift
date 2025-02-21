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
        XCTAssert(Parent.router.match("/courses/1/grades") is CourseDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/assignments/syllabus") is SyllabusViewController)
        XCTAssert(Parent.router.match("/conversations") is CoreHostingController<InboxView>)
        XCTAssert(Parent.router.match("/conversations/1") is CoreHostingController<MessageDetailsView>)
        XCTAssert(Parent.router.match("/calendar") is PlannerViewController)
        XCTAssert(Parent.router.match("/calendar?event_id=1") is Parent.CalendarEventDetailsViewController)
        XCTAssert(Parent.router.match("/calendar_events/1") is Parent.CalendarEventDetailsViewController)
        XCTAssert(Parent.router.match("/users/1/calendar_events/1") is Parent.CalendarEventDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/assignments/1") is AssignmentDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/assignments/1/submissions/1") is AssignmentDetailsViewController)

        XCTAssert(Parent.router.match("/files/1") is FileDetailsViewController)
        XCTAssert(Parent.router.match("/files/2/download") is FileDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/files/3") is FileDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/files/4/download") is FileDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/files/4/preview") is FileDetailsViewController)

        XCTAssert(Parent.router.match("/courses/1/pages/test-page") is PageDetailsViewController)
        XCTAssert(Parent.router.match("/courses/1/wiki/test-wiki") is PageDetailsViewController)
    }
}
