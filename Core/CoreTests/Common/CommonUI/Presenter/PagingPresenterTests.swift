//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class PagingPresenterTests: XCTestCase {

    private var controller: TestPageViewController!
    private var paging: PagingPresenter<TestPageViewController>!

    override func setUp() {
        super.setUp()

        controller = TestPageViewController()
        paging = PagingPresenter(controller: controller)
    }

    func test_hasMore() {
        paging.onPageLoaded(TestPageModel(nextCursor: "example_cursor"))
        XCTAssertTrue(paging.hasMore)

        paging.onPageLoaded(TestPageModel())
        XCTAssertFalse(paging.hasMore)
    }

    func test_pageLoading_success() {
        // Given
        let model = TestPageModel(nextCursor: "cursor_1")
        let lastIndex = IndexPath(row: 0, section: 1)
        controller.lastRowIndex = lastIndex
        paging.onPageLoaded(model)

        // When
        paging.willDisplayRow(at: lastIndex)

        // Then
        XCTAssertTrue(paging.isLoadingMore)
        XCTAssertEqual(controller.nextPageCallCount, 1)

        // When
        paging.onPageLoaded(TestPageModel(nextCursor: "cursor_2"))

        // Then
        XCTAssertFalse(paging.isLoadingMore)

        // When
        paging.willDisplayRow(at: lastIndex)

        // Then
        XCTAssertTrue(paging.isLoadingMore)
        XCTAssertEqual(controller.nextPageCallCount, 2)

        // When
        paging.onPageLoaded(TestPageModel())

        // When
        paging.willDisplayRow(at: lastIndex)

        // Then
        XCTAssertFalse(paging.isLoadingMore)
        XCTAssertEqual(controller.nextPageCallCount, 2)
    }

    func test_pageLoading_failure() {
        // Given
        let model = TestPageModel(nextCursor: "cursor_1")
        let lastIndex = IndexPath(row: 0, section: 1)
        controller.lastRowIndex = lastIndex
        paging.onPageLoaded(model)

        // When - first page
        paging.willDisplayRow(at: lastIndex)

        // Then
        XCTAssertTrue(paging.isLoadingMore)
        XCTAssertEqual(controller.nextPageCallCount, 1)

        // When - failure
        paging.onPageLoadingFailed()

        // Then
        XCTAssertFalse(paging.isLoadingMore)

        // When - last row displayed again
        paging.willDisplayRow(at: lastIndex)

        // Then
        XCTAssertFalse(paging.isLoadingMore)
        XCTAssertEqual(controller.nextPageCallCount, 1)

        // When - last row was tapped
        paging.willSelectRow(at: lastIndex)

        // Then
        XCTAssertTrue(paging.isLoadingMore)
        XCTAssertEqual(controller.nextPageCallCount, 2)

        // When - success
        paging.onPageLoaded(TestPageModel())

        // Then
        XCTAssertFalse(paging.isLoadingMore)
    }
}

struct TestPageModel: PageModel {
    var nextCursor: String?
}

private class TestPageViewController: UIViewController, PagingViewController {
    typealias Page = TestPageModel

    var lastRowIndex: IndexPath?
    func isMoreRow(at indexPath: IndexPath) -> Bool {
        lastRowIndex == indexPath
    }

    var nextPageCallCount: Int = 0
    func loadNextPage() {
        nextPageCallCount += 1
    }
}
