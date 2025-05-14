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

class GetPageTests: CoreTestCase {
    let context = Context(.course, id: "1")
    let pageURL = "page-test"

    func testEncodedString() {
        XCTAssertEqual(GetPage(context: context, url: "pipe-%7C-pipe").url, "pipe-|-pipe")
        XCTAssertEqual(UpdatePage(context: context, url: "`").url, "%60")
    }

    func testCacheKey() {
        XCTAssertEqual(GetPage(context: context, url: pageURL).cacheKey, "get-course_1-page-page-test")
    }

    func testMakeRequest() {
        api.mock(GetPageRequest(context: context, url: pageURL), value: .make(page_id: "1"))
        let useCase = GetPage(context: context, url: pageURL)
        let expectation = XCTestExpectation(description: "completion handler")
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.page_id, "1")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequestFrontPage() {
        api.mock(GetFrontPageRequest(context: context), value: .make(front_page: true, page_id: "2"))
        let useCase = GetPage(context: context, url: "front_page")
        let expectation = XCTestExpectation(description: "completion handler")
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.page_id, "2")
            XCTAssertEqual(response?.front_page, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testScope() {
        let scope = GetPage(context: context, url: pageURL).scope
        XCTAssertEqual(scope.predicate, NSPredicate(format: "%K == %@ && %K == %@", #keyPath(Page.contextID), context.canvasContextID, #keyPath(Page.url), pageURL))
    }

    func testScopeFrontPage() {
        let scope = GetPage(context: context, url: "front_page").scope
        let match = Page.make(from: .make(front_page: true, html_url: URL(string: context.pathComponent)!, page_id: "1"))
        let mismatch = Page.make(from: .make(front_page: false, html_url: URL(string: context.pathComponent)!, page_id: "2"))
        XCTAssertTrue(scope.predicate.evaluate(with: match))
        XCTAssertFalse(scope.predicate.evaluate(with: mismatch))
    }

    func testReset() {
        let previous = Page.make(from: .make(front_page: true, html_url: URL(string: context.pathComponent)!, page_id: "1"))
        GetPage(context: context, url: "front_page").reset(context: databaseClient)
        XCTAssertFalse(previous.isFrontPage)
    }

    /// We request a page by URL and the response is a renamed page with a different url
    func testRenamedPage() {
        let useCase = GetPage(context: .course("42"), url: "original-url")
        useCase.write(response: .make(url: "renamed-url"), urlResponse: nil, to: databaseClient)
        let pages: [Page] = databaseClient.fetch(scope: useCase.scope)

        guard pages.count == 1, let page = pages.first else {
            return XCTFail()
        }

        XCTAssertEqual(page.url, "original-url")
    }
}
