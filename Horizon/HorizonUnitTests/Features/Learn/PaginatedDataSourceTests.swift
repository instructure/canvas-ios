//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import XCTest

final class PaginatedDataSourceTests: HorizonTestCase {
    private struct TestItem: ProgressStatusProvidable, Equatable {
        let id: String
        let name: String
        let status: ProgressStatus

        init(id: String, name: String, progress: Double) {
            self.id = id
            self.name = name
            self.status = ProgressStatus(progress: progress)
        }

        init(id: String, name: String, status: ProgressStatus) {
            self.id = id
            self.name = name
            self.status = status
        }
    }

    // MARK: - Properties

    private var testee: PaginatedDataSource<TestItem>!

    // MARK: - Setup & Teardown

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_withEmptyItems_shouldSetEmptyVisibleItems() {
        testee = PaginatedDataSource(items: [])

        XCTAssertEqual(testee.visibleItems.count, 0)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_init_withLessThanPageSize_shouldShowAllItems() {
        let items = createTestItems(count: 5)
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 5)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_init_withExactlyPageSize_shouldShowFirstPage() {
        let items = createTestItems(count: 10)
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 10)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_init_withMoreThanPageSize_shouldShowFirstPageAndSeeMore() {
        let items = createTestItems(count: 15)
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 10)
        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    func test_init_withCustomPageSize_shouldRespectPageSize() {
        let items = createTestItems(count: 15)
        testee = PaginatedDataSource(items: items, pageSize: 5)

        XCTAssertEqual(testee.visibleItems.count, 5)
        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    // MARK: - SetItems Tests

    func test_setItems_shouldUpdateVisibleItems() {
        testee = PaginatedDataSource(items: [])
        let items = createTestItems(count: 8)

        testee.setItems(items)

        XCTAssertEqual(testee.visibleItems.count, 8)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_setItems_shouldResetPagination() {
        let items = createTestItems(count: 25)
        testee = PaginatedDataSource(items: items)

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 20)

        testee.setItems(createTestItems(count: 5))

        XCTAssertEqual(testee.visibleItems.count, 5)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    // MARK: - SeeMore Tests

    func test_seeMore_shouldShowNextPage() {
        let items = createTestItems(count: 15)
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 10)
        XCTAssertTrue(testee.isSeeMoreVisible)

        testee.seeMore()

        XCTAssertEqual(testee.visibleItems.count, 15)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_seeMore_withMultiplePages_shouldShowPagesSequentially() {
        let items = createTestItems(count: 25)
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 10)

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 20)
        XCTAssertTrue(testee.isSeeMoreVisible)

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 25)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_seeMore_whenNoMorePages_shouldNotChangeVisibleItems() {
        let items = createTestItems(count: 10)
        testee = PaginatedDataSource(items: items)

        let initialCount = testee.visibleItems.count
        testee.seeMore()

        XCTAssertEqual(testee.visibleItems.count, initialCount)
    }

    func test_seeMore_whenCalledMultipleTimesAtEnd_shouldNotCrash() {
        let items = createTestItems(count: 15)
        testee = PaginatedDataSource(items: items)

        testee.seeMore()
        testee.seeMore()
        testee.seeMore()

        XCTAssertEqual(testee.visibleItems.count, 15)
    }

    // MARK: - Search Tests (with ProgressStatusProvidable)

    func test_search_withEmptyQuery_shouldShowAllItemsForSelectedStatus() {
        let items = createMixedStatusItems()
        testee = PaginatedDataSource(items: items)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))

        XCTAssertEqual(testee.visibleItems.count, 10)
    }

    func test_search_withQuery_shouldFilterByName() {
        let items = [
            TestItem(id: "1", name: "iOS Development", progress: 50),
            TestItem(id: "2", name: "Android Development", progress: 50),
            TestItem(id: "3", name: "iOS Testing", progress: 50)
        ]
        testee = PaginatedDataSource(items: items)

        testee.search(query: "iOS", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))

        XCTAssertEqual(testee.visibleItems.count, 2)
        XCTAssertTrue(testee.visibleItems.allSatisfy { $0.name.contains("iOS") })
    }

    func test_search_isCaseInsensitive() {
        let items = [
            TestItem(id: "1", name: "iOS Development", progress: 50),
            TestItem(id: "2", name: "Android Development", progress: 50)
        ]
        testee = PaginatedDataSource(items: items)

        testee.search(query: "ios", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))

        XCTAssertEqual(testee.visibleItems.count, 1)
        XCTAssertEqual(testee.visibleItems.first?.name, "iOS Development")
    }

    func test_search_byStatus_completed_shouldShowOnlyCompletedItems() {
        let items = createMixedStatusItems()
        testee = PaginatedDataSource(items: items)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.completed.rawValue, name: "Completed"))

        XCTAssertTrue(testee.visibleItems.allSatisfy { $0.status == .completed })
    }

    func test_search_byStatus_inProgress_shouldShowOnlyInProgressItems() {
        let items = createMixedStatusItems()
        testee = PaginatedDataSource(items: items)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.inProgress.rawValue, name: "In progress"))

        XCTAssertTrue(testee.visibleItems.allSatisfy { $0.status == .inProgress })
    }

    func test_search_byStatus_notStarted_shouldShowOnlyNotStartedItems() {
        let items = createMixedStatusItems()
        testee = PaginatedDataSource(items: items)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.notStarted.rawValue, name: "Not started"))

        XCTAssertTrue(testee.visibleItems.allSatisfy { $0.status == .notStarted })
    }

    func test_search_combiningQueryAndStatus_shouldFilterByBoth() {
        let items = [
            TestItem(id: "1", name: "iOS Development", progress: 100),
            TestItem(id: "2", name: "iOS Testing", progress: 50),
            TestItem(id: "3", name: "Android Development", progress: 100),
            TestItem(id: "4", name: "iOS Advanced", progress: 0)
        ]
        testee = PaginatedDataSource(items: items)

        testee.search(query: "iOS", status: OptionModel(id: ProgressStatus.completed.rawValue, name: "Completed"))

        XCTAssertEqual(testee.visibleItems.count, 1)
        XCTAssertEqual(testee.visibleItems.first?.name, "iOS Development")
        XCTAssertEqual(testee.visibleItems.first?.status, .completed)
    }

    func test_search_withNoMatches_shouldReturnEmptyArray() {
        let items = createTestItems(count: 10)
        testee = PaginatedDataSource(items: items)

        testee.search(query: "NonExistentItem", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))

        XCTAssertEqual(testee.visibleItems.count, 0)
    }

    func test_search_resetsPagination() {
        let items = createTestItems(count: 25)
        testee = PaginatedDataSource(items: items)

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 20)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))

        XCTAssertEqual(testee.visibleItems.count, 10)
    }

    // MARK: - IsSeeMoreVisible Tests

    func test_isSeeMoreVisible_withMultiplePages_shouldReturnTrue() {
        let items = createTestItems(count: 15)
        testee = PaginatedDataSource(items: items)

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    func test_isSeeMoreVisible_withSinglePage_shouldReturnFalse() {
        let items = createTestItems(count: 5)
        testee = PaginatedDataSource(items: items)

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_isSeeMoreVisible_afterSeeingAllPages_shouldReturnFalse() {
        let items = createTestItems(count: 15)
        testee = PaginatedDataSource(items: items)

        testee.seeMore()

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    // MARK: - Edge Cases Tests

    func test_emptyItems_shouldHandleAllOperations() {
        testee = PaginatedDataSource(items: [])

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 0)

        testee.search(query: "test", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))
        XCTAssertEqual(testee.visibleItems.count, 0)
    }

    func test_singleItem_shouldHandlePaginationCorrectly() {
        let items = [TestItem(id: "1", name: "Single Item", progress: 50)]
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 1)
        XCTAssertFalse(testee.isSeeMoreVisible)

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 1)
    }

    func test_exactMultipleOfPageSize_shouldHandlePaginationCorrectly() {
        let items = createTestItems(count: 20)
        testee = PaginatedDataSource(items: items)

        XCTAssertEqual(testee.visibleItems.count, 10)
        XCTAssertTrue(testee.isSeeMoreVisible)

        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 20)
        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    func test_searchAfterMultipleSeeMore_shouldResetCorrectly() {
        let items = createTestItems(count: 35)
        testee = PaginatedDataSource(items: items)

        testee.seeMore()
        testee.seeMore()
        XCTAssertEqual(testee.visibleItems.count, 30)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))

        XCTAssertEqual(testee.visibleItems.count, 10)
        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    func test_multipleSearchCalls_shouldUpdateCorrectly() {
        let items = [
            TestItem(id: "1", name: "iOS Development", progress: 100),
            TestItem(id: "2", name: "iOS Testing", progress: 50),
            TestItem(id: "3", name: "Android Development", progress: 0)
        ]
        testee = PaginatedDataSource(items: items)

        testee.search(query: "iOS", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))
        XCTAssertEqual(testee.visibleItems.count, 2)

        testee.search(query: "Android", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))
        XCTAssertEqual(testee.visibleItems.count, 1)

        testee.search(query: "", status: OptionModel(id: ProgressStatus.all.rawValue, name: "All"))
        XCTAssertEqual(testee.visibleItems.count, 3)
    }

    // MARK: - Helper Methods

    private func createTestItems(count: Int) -> [TestItem] {
        (1...count).map { index in
            TestItem(id: "\(index)", name: "Item \(index)", progress: 50)
        }
    }

    private func createMixedStatusItems() -> [TestItem] {
        [
            TestItem(id: "1", name: "Completed 1", progress: 100),
            TestItem(id: "2", name: "Completed 2", progress: 100),
            TestItem(id: "3", name: "Completed 3", progress: 100),
            TestItem(id: "4", name: "In Progress 1", progress: 50),
            TestItem(id: "5", name: "In Progress 2", progress: 75),
            TestItem(id: "6", name: "In Progress 3", progress: 25),
            TestItem(id: "7", name: "Not Started 1", progress: 0),
            TestItem(id: "8", name: "Not Started 2", progress: 0),
            TestItem(id: "9", name: "Not Started 3", progress: 0),
            TestItem(id: "10", name: "Not Started 4", progress: 0)
        ]
    }
}
