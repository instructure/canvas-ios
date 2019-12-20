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

        XCTAssertNil(Parent.router.match(Route.conversations.url))
        XCTAssertNil(Parent.router.match(Route.compose().url))
        XCTAssertNil(Parent.router.match(Route.conversation("1").url))
        ExperimentalFeature.parentInbox.isEnabled = true
        XCTAssert(Parent.router.match(Route.conversations.url) is ConversationListViewController)
        XCTAssertEqual((Parent.router.match(Route.compose(observeeID: "2").url) as? ComposeViewController)?.observeeID, "2")
        XCTAssert(Parent.router.match(Route.conversation("1").url) is ConversationDetailViewController)
    }
}
