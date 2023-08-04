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

import TestsFoundation

class DiscussionEditE2ETests: CoreUITestCase {
    let gradedDiscussionId = "14393"
    let simpleDiscussionId = "14392"

    override func setUp() {
        super.setUp()
        let discussionsButton = CourseDetailsHelper.cell(type: .discussions)
        DashboardHelper.courseCard(courseId: "263").actionUntilElementCondition(action: .tap, element: discussionsButton, condition: .visible)
        discussionsButton.hit()
        DiscussionsHelper.discussionButton(discussionId: gradedDiscussionId).waitUntil(.visible)
    }

    func testEditDiscussion() throws {
        DiscussionsHelper.discussionButton(discussionId: simpleDiscussionId).hit()
        let optionsButton = DiscussionsHelper.Details.optionsButton.waitUntil(.visible)
        let editButton = app.find(label: "Edit")
        optionsButton.actionUntilElementCondition(action: .tap, element: editButton, condition: .visible)
        editButton.hit()

        XCTAssertTrue(DiscussionsHelper.Editor.titleField.waitUntil(.visible).isVisible)
    }
}
