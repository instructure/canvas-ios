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

class PagesE2ETests: CoreUITestCase {
    func testCreateAndDeletePage() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.pages.tap()

        PageList.frontPage.tap()
        app.find(labelContaining: "This is a page for testing modules").waitToExist()
        NavBar.backButton.tap()
        PageList.add.tap()

        PageEditor.doneButton.waitToExist()
        PageEditor.titleField.typeText("New Page")
        PageEditor.publishedToggle.tap()
        PageEditor.doneButton.tap()
        PageList.add.waitToExist()
        app.swipeDown()

        let editedPageTitle = "New Edited Page"
        PageList.page(index: 2).tap()
        PageDetails.options.waitToExist()
        PageDetails.options.tap()
        app.find(label: "Edit").tap()
        PageEditor.doneButton.waitToExist()
        PageEditor.titleField.cutText()
        PageEditor.titleField.typeText(editedPageTitle)
        PageEditor.doneButton.tap()
        NavBar.backButton.tap()

        PageList.add.waitToExist()
        app.find(label: editedPageTitle).tap()
        PageDetails.options.tap()
        app.find(label: "Delete").tap()
        app.find(label: "OK").tap()
        XCTAssertEqual(app.find(label: editedPageTitle).exists(), false)
    }
}
