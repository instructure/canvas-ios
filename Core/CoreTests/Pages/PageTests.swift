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
@testable import Core

class PageTests: CoreTestCase {
    func testCreatesPage() {
        var page: Page? = databaseClient.fetch().first
        XCTAssertNil(page)

        Page.save(APIPage.make(), in: databaseClient)
        try! databaseClient.save()
        page = databaseClient.fetch().first
        XCTAssertNotNil(page)
    }

    func testUpdatesPage() {
        Page.make(from: .make(page_id: "1"))
        Page.save(.make(page_id: "1"), in: databaseClient)

        let pages: [Page] = databaseClient.fetch()
        XCTAssertEqual(pages.count, 1)
    }

    func testUpdate() {
        let page = Page.make()

        let update = APIPage.make(
            body: "This is only a test",
            editing_roles: "teacher,public",
            front_page: true,
            html_url: URL(string: "https://canvas.instructure.com/courses/1/pages/test-test")!,
            page_id: ID("2"),
            published: true,
            title: "Test Test",
            updated_at: Date(),
            url: "test-test"
        )
        page.update(from: update)

        XCTAssertEqual(page.url, update.url)
        XCTAssertEqual(page.lastUpdated, update.updated_at)
        XCTAssertEqual(page.isFrontPage, update.front_page)
        XCTAssertEqual(page.id, update.page_id.value)
        XCTAssertEqual(page.title, update.title)
        XCTAssertEqual(page.htmlURL, update.html_url)
        XCTAssertEqual(page.published, update.published)
        XCTAssertEqual(page.body, update.body)
        XCTAssertEqual(page.editingRoles, ["teacher", "public"])
        XCTAssertEqual(page.contextID, "course_1")
    }

    func testOptionalProperties() {
        let page = Page.make(from: .make(
            body: "Test",
            editing_roles: "teacher"
        ))

        page.update(from: .make())
        XCTAssertEqual(page.body, "")
        XCTAssertEqual(page.editingRoles, [])
    }
}
