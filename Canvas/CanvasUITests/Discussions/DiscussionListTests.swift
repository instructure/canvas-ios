//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

class DiscussionListTests: CanvasUITests {
    override func setUp() {
        super.setUp()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()
        DiscussionListCell.graded.waitToExist()
    }

    func testDiscussionListShowsDueDate() {
        XCTAssert(DiscussionListCell.graded.label.contains("Due Dec"))
        XCTAssertFalse(DiscussionListCell.simple.label.contains("Due"))
    }

    func testDiscussionListShowsDetails() {
        XCTAssert(DiscussionListCell.graded.label.contains("Graded Discussion"))
        XCTAssert(DiscussionListCell.graded.label.contains("Due Dec"))
        XCTAssert(DiscussionListCell.graded.label.contains("10 pts"))
        XCTAssert(DiscussionListCell.graded.label.contains("0 Replies"))
        XCTAssert(DiscussionListCell.graded.label.contains("0 Unread"))

        XCTAssert(DiscussionListCell.simple.label.contains("Simple Discussion"))
        XCTAssert(DiscussionListCell.simple.label.contains("Last post Jun"))
        XCTAssert(DiscussionListCell.simple.label.contains("1 Reply"))
        XCTAssert(DiscussionListCell.simple.label.contains("0 Unread"))
    }
}
