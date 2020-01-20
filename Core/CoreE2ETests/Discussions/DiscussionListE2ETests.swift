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

import XCTest
import TestsFoundation
@testable import CoreUITests

class DiscussionListE2ETests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return DiscussionListE2ETests.self }

    override func setUp() {
        super.setUp()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()
        DiscussionListCell.graded.waitToExist()
    }

    func testDiscussionListShowsDueDate() {
        XCTAssert(DiscussionListCell.graded.label().contains("Due Dec"))
        XCTAssertFalse(DiscussionListCell.simple.label().contains("Due"))
    }

    func testDiscussionListShowsDetails() {
        XCTAssert(DiscussionListCell.graded.label().contains("Graded Discussion"))
        XCTAssert(DiscussionListCell.graded.label().contains("Due Dec"))
        XCTAssert(DiscussionListCell.graded.label().contains("10 pts"))
        XCTAssert(DiscussionListCell.graded.label().contains("0 Replies"))
        XCTAssert(DiscussionListCell.graded.label().contains("0 Unread"))

        XCTAssert(DiscussionListCell.simple.label().contains("Simple Discussion"))
        XCTAssert(DiscussionListCell.simple.label().contains("Last post Jun"))
        XCTAssert(DiscussionListCell.simple.label().contains("1 Reply"))
        XCTAssert(DiscussionListCell.simple.label().contains("0 Unread"))
    }
}
