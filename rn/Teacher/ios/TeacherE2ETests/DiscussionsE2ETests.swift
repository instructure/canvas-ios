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

import XCTest
import TestsFoundation

class DiscussionsE2ETests: CoreUITestCase {
    func testDiscussionsE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.discussions.tap()
        DiscussionList.newButton.waitToExist()
        DiscussionListCell.cell(id: "14393").tap()
        XCTAssertEqual(DiscussionDetails.title.label(), "Graded Discussion")
        NavBar.backButton.tap()
        DiscussionListCell.cell(id: "14392").tap()
        XCTAssertEqual(DiscussionDetails.title.label(), "Simple Discussion")
        app.find(labelContaining: "No Attachment").waitToExist()
        DiscussionDetails.options.tap()
        DiscussionDetails.edit.tap()
        DiscussionEditor.doneButton.waitToExist()
        app.find(label: "Cancel").tap()
        DiscussionDetails.title.waitToExist()
        NavBar.backButton.tap()
        DiscussionList.newButton.tap()
        DiscussionEditor.doneButton.waitToExist()
        app.find(label: "Cancel").tap()
    }
}
