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
@testable import Core

class PagesUITests: MiniCanvasUITestCase {
    func testNavigateToPage() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.pages.tap()
        XCTAssertEqual(PageList.frontPageTitle.label(), firstCourse.pages[0].title)
        XCTAssertEqual(PageList.page(index: 0).label(), firstCourse.pages[1].title)
        PageList.frontPage.tap().waitToVanish()
        // TitleSubtitle is hidden to a11y in iOS for some reason
        // XCTAssertEqual(NavBar.title.label(), firstCourse.pages[0].title)
        app.find(label: firstCourse.pages[0].body!).waitToExist()
    }

    func testCreatePage() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.pages.tap()
        PageList.add.tap()

        PageEditor.titleField.typeText("Paaaage")
        app.webViews.firstElement.typeText("Content")
        PageEditor.publishedToggle.tap()
        PageEditor.frontPageToggle.waitToExist()

        let expectation = MiniCanvasServer.shared.expectationForRequest(
            "/api/v1/courses/\(firstCourse.id)/pages",
            method: .post
        )
        PageEditor.doneButton.tap()
        wait(for: [expectation], timeout: 3)
    }

    func testPublishPage() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.pages.tap()
        PageList.page(index: 0).tap()
        PageDetails.options.tap()
        app.find(label: "Edit").tap()
        PageEditor.publishedToggle.tap()

        let expectation = MiniCanvasServer.shared.expectationForRequest(
            "/api/v1/courses/\(firstCourse.id)/pages/\(firstCourse.pages[1].url)",
            method: .put
        )
        PageEditor.doneButton.tap()
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(firstCourse.pages[1].published)
    }
}
