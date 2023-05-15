//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

@testable import Core
import Foundation
import TestsFoundation
import XCTest

class CourseSyncPagesInteractorLiveTests: CoreTestCase {
    func testFrontAndRegularPages() {
        let testee = CourseSyncPagesInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        let getFrontPageUseCase = GetFrontPage(context: .course("1"))
        let frontPage = APIPage.make(
            front_page: true,
            html_url: URL(string: "1")!,
            page_id: ID("1"),
            url: "1"
        )
        api.mock(getFrontPageUseCase, value: frontPage)

        let getPagesUseCase = GetPages(context: .course("1"))
        let page = APIPage.make(
            front_page: false,
            html_url: URL(string: "2")!,
            page_id: ID("2"),
            url: "2"
        )
        api.mock(getPagesUseCase, value: [page])

        let subscription = testee.getContent(courseId: "1")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        let pageList: [Page] = databaseClient.fetch(
            nil,
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Page.id), ascending: true)]
        )
        XCTAssertEqual(pageList.count, 2)
        XCTAssertEqual(pageList[0].id, "1")
        XCTAssertEqual(pageList[1].id, "2")
        subscription.cancel()
    }

    func testRegularPagesWithoutFrontPage() {
        let testee = CourseSyncPagesInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        let getFrontPageUseCase = GetFrontPage(context: .course("1"))
        api.mock(getFrontPageUseCase, error: NSError.instructureError("Front page not found"))

        let getPagesUseCase = GetPages(context: .course("1"))
        let page = APIPage.make(
            front_page: false,
            html_url: URL(string: "2")!,
            page_id: ID("2"),
            url: "2"
        )
        api.mock(getPagesUseCase, value: [page])

        let subscription = testee.getContent(courseId: "1")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        let pageList: [Page] = databaseClient.fetch(nil, sortDescriptors: nil)
        XCTAssertEqual(pageList.count, 1)
        XCTAssertEqual(pageList[0].id, "2")
        subscription.cancel()
    }

    func testErrorHandling() {
        let testee = CourseSyncPagesInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        let getFrontPageUseCase = GetFrontPage(context: .course("1"))
        api.mock(getFrontPageUseCase, error: NSError.instructureError("Front page not found"))

        let getPagesUseCase = GetPages(context: .course("1"))
        api.mock(getPagesUseCase, error: NSError.instructureError("Page not found"))

        let subscription = testee.getContent(courseId: "1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        expectation.fulfill()
                    default:
                        break
                    }
                },
                receiveValue: { _ in }
            )

        waitForExpectations(timeout: 0.1)
        let pageList: [Page] = databaseClient.fetch(nil, sortDescriptors: nil)
        XCTAssertEqual(pageList.count, 0)
        subscription.cancel()
    }
}
