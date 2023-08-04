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

class PagesE2ETests: CoreUITestCase {
    func testCreateAndDeletePage() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .pages).hit()

        PagesHelper.frontPage.hit()
        app.find(labelContaining: "This is a page for testing modules").waitUntil(.visible)
        PagesHelper.backButton.hit()
        PagesHelper.add.hit()

        PagesHelper.Editor.done.waitUntil(.visible)
        PagesHelper.Editor.title.writeText(text: "New Page")
        PagesHelper.Editor.published.hit()
        PagesHelper.Editor.done.hit()
        PagesHelper.add.waitUntil(.visible)
        app.swipeDown()

        let editedPageTitle = "New Edited Page"
        PagesHelper.page(index: 2).hit()
        PagesHelper.Details.options.hit()
        app.find(label: "Edit").hit()
        PagesHelper.Editor.done.waitUntil(.visible)
        PagesHelper.Editor.title.cutText()
        PagesHelper.Editor.title.writeText(text: editedPageTitle)
        PagesHelper.Editor.done.hit()
        PagesHelper.backButton.hit()

        PagesHelper.add.waitUntil(.visible)
        app.find(label: editedPageTitle).hit()
        PagesHelper.Details.options.hit()
        app.find(label: "Delete").hit()
        app.find(label: "OK").hit()
        XCTAssertFalse(app.find(label: editedPageTitle).waitUntil(.vanish).isVisible)
    }
}
