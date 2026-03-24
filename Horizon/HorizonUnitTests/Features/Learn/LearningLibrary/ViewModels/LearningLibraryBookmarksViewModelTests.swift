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

@testable import Horizon
@testable import Core
import XCTest
import Combine
import CombineSchedulers

final class LearningLibraryBookmarksViewModelTests: HorizonTestCase {

    // MARK: - Fetch Data Tests

    func testFetchDataLoadsBookmarkedItems() {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Bookmarked Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 5,
                isEnrolled: false
            )
        ]
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: mockItems)
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasItems)
        XCTAssertEqual(testee.filteredItems.count, 1)
    }

    func testFetchDataWithEmptyResponse() {
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: [])
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasItems)
    }

    func testFetchDataCallsCompletion() {
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: [])
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )
        let expectation = expectation(description: "Completion called")

        testee.fetchData { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - Refresh Tests

    func testRefreshReloadsData() async {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Test Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "60",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 5,
                isEnrolled: false
            )
        ]
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: mockItems)
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        await testee.refresh()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasItems)
    }

    // MARK: - Filter Tests

    func testAppliedFiltersCountWithNoFilters() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.appliedFiltersCount, 0)
    }

    func testAppliedFiltersCountWithSortOption() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        testee.selectedSortOption = .nameAZ

        XCTAssertEqual(testee.appliedFiltersCount, 1)
    }

    func testAppliedFiltersCountWithFilterTypes() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        testee.selectedFilterTypes = [.course, .page]

        XCTAssertEqual(testee.appliedFiltersCount, 2)
    }

    // MARK: - Bookmark Tests

    func testAddBookmarkRemovesItemFromList() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: false,
            isCompleted: false,
            isBookmarked: true,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let updatedCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: false,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(
            bookmarkedItems: [mockCard],
            bookmarkResponse: updatedCard
        )
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )
        testee.fetchData()
        XCTAssertEqual(testee.filteredItems.count, 1)

        testee.addBookmark(model: mockCard)

        XCTAssertEqual(testee.filteredItems.count, 0)
        XCTAssertFalse(testee.hasItems)
    }

    // MARK: - Pagination Tests

    func testSeeMoreShowsMoreItems() {
        let items = (1...20).map { i in
            LearningLibraryCardModel(
                id: "item-\(i)",
                courseID: "course-\(i)",
                name: "Course \(i)",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "60",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 5,
                isEnrolled: false
            )
        }
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: items)
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )
        testee.fetchData()
        let initialCount = testee.filteredItems.count

        testee.seeMore()

        XCTAssertGreaterThan(testee.filteredItems.count, initialCount)
    }

    func testIsSeeMoreVisibleWhenMoreItemsAvailable() {
        let items = (1...20).map { i in
            LearningLibraryCardModel(
                id: "item-\(i)",
                courseID: "course-\(i)",
                name: "Course \(i)",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "60",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 5,
                isEnrolled: false
            )
        }
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: items)
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    // MARK: - Initial State Tests

    func testInitialStateShowsLoader() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertTrue(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasItems)
        XCTAssertFalse(testee.isErrorVisible)
    }

    func testInitialSearchTextIsEmpty() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryBookmarksViewModel(
            interactor: interactor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.searchText, "")
    }
}
