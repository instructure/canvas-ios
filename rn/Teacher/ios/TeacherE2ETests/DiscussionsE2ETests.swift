//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import TestsFoundation

class DiscussionsE2ETests: CoreUITestCase {
    func testDiscussionsE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .discussions).hit()
        XCTAssertTrue(DiscussionsHelper.newButton.waitUntil(.visible).isVisible)
        DiscussionsHelper.discussionButton(discussionId: "14393").hit()
        XCTAssertEqual(DiscussionsHelper.Details.titleLabel.waitUntil(.visible).label, "Graded Discussion")
        DiscussionsHelper.backButton.hit()
        DiscussionsHelper.discussionButton(discussionId: "14392").hit()
        XCTAssertEqual(DiscussionsHelper.Details.titleLabel.waitUntil(.visible).label, "Simple Discussion")
        XCTAssertTrue(app.find(labelContaining: "No Attachment").waitUntil(.visible).isVisible)
        DiscussionsHelper.Details.optionsButton.hit()
        DiscussionsHelper.Details.editButton.hit()
        XCTAssertTrue(DiscussionsHelper.Editor.doneButton.waitUntil(.visible).isVisible)
        app.find(label: "Cancel").hit()
        XCTAssertTrue(DiscussionsHelper.Details.titleLabel.waitUntil(.visible).isVisible)
        DiscussionsHelper.backButton.hit()
        DiscussionsHelper.newButton.hit()
        XCTAssertTrue(DiscussionsHelper.Editor.doneButton.waitUntil(.visible).isVisible)
        app.find(label: "Cancel").hit()
    }
}
