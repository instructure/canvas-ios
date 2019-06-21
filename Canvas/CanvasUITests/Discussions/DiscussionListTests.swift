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
    func testDiscussionListShowsDueDate() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()

        DiscussionList.cell(index: 0).waitToExist()
        XCTAssert(DiscussionList.cell(index: 0).label.contains("Due Dec"))
        XCTAssertFalse(DiscussionList.cell(index: 1).label.contains("Due"))
    }

    func testDiscussionListShowsDetails() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()

        DiscussionList.cell(index: 0).waitToExist()
        XCTAssert(DiscussionList.cell(index: 0).label.contains("Graded Discussion"))
        XCTAssert(DiscussionList.cell(index: 0).label.contains("Due Dec"))
        XCTAssert(DiscussionList.cell(index: 0).label.contains("10 pts"))
        XCTAssert(DiscussionList.cell(index: 0).label.contains("0 Replies"))
        XCTAssert(DiscussionList.cell(index: 0).label.contains("0 Unread"))

        XCTAssert(DiscussionList.cell(index: 1).label.contains("Simple Discussion"))
        XCTAssert(DiscussionList.cell(index: 1).label.contains("Last post Jun"))
        XCTAssert(DiscussionList.cell(index: 1).label.contains("0 Replies"))
        XCTAssert(DiscussionList.cell(index: 1).label.contains("0 Unread"))
    }
}
