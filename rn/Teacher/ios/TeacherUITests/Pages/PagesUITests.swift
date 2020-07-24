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
        XCTAssertEqual(NavBar.title.label(), firstCourse.pages[0].title)
        app.find(label: firstCourse.pages[0].body!).waitToExist()
    }

    func testCreatePage() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.pages.tap()
        PageList.add.tap()

        PageEdit.title.typeText("Paaaage")
        app.webViews.firstElement.typeText("Content")
        PageEdit.published.tap()
        PageEdit.frontPage.waitToExist()

        let expectation = MiniCanvasServer.shared.expectationForRequest(
            "/api/v1/courses/\(firstCourse.id)/pages",
            method: .post
        )
        PageEdit.done.tap()
        wait(for: [expectation], timeout: 3)
    }

    func testPublishPage() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.pages.tap()
        PageList.page(index: 0).tap()
        PageDetails.options.tap()
        app.find(label: "Edit").tap()
        PageEdit.published.tap()

        let expectation = MiniCanvasServer.shared.expectationForRequest(
            "/api/v1/courses/\(firstCourse.id)/pages/\(firstCourse.pages[1].url)",
            method: .put
        )
        PageEdit.done.tap()
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(firstCourse.pages[1].published)
    }
}
