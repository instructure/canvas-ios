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

final class LearningLibraryViewModelTests: HorizonTestCase {

    // MARK: - Fetch Collections Tests

    func testFetchCollectionsSuccessShowsData() {
        let mockSection1 = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: true,
            items: []
        )
        let mockSection2 = LearningLibrarySectionModel(
            id: "section-2",
            name: "Trending",
            hasMoreItems: false,
            items: []
        )
        let interactor = LearningLibraryInteractorMock(collections: [mockSection1, mockSection2])
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.fetchCollections()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasLibrary)
        XCTAssertEqual(testee.filteredSections.count, 2)
    }

    func testFetchCollectionsEmptyResponseHidesLoader() {
        let interactor = LearningLibraryInteractorMock(collections: [])
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.fetchCollections()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasLibrary)
        XCTAssertEqual(testee.filteredSections.count, 0)
    }

    func testFetchCollectionsErrorShowsError() {
        let interactor = LearningLibraryInteractorMock(hasError: true)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.fetchCollections()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
    }

    func testFetchCollectionsWithIgnoreCache() {
        let mockSection = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: false,
            items: []
        )
        let interactor = LearningLibraryInteractorMock(collections: [mockSection])
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.fetchCollections(ignoreCache: true)

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasLibrary)
    }

    func testFetchCollectionsCallsCompletion() {
        let interactor = LearningLibraryInteractorMock(collections: [])
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )
        let expectation = expectation(description: "Completion called")

        testee.fetchCollections { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - Refresh Tests

    func testRefreshReloadsCollections() async {
        let mockSection = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: false,
            items: []
        )
        let interactor = LearningLibraryInteractorMock(collections: [mockSection])
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        await testee.refresh()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasLibrary)
    }

    // MARK: - Bookmark Tests

    func testAddBookmarkUpdatesItem() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
        let updatedCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
        let mockSection = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: false,
            items: [mockCard]
        )
        let interactor = LearningLibraryInteractorMock(
            collections: [mockSection],
            bookmarkResponse: updatedCard
        )
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )
        testee.fetchCollections()

        testee.addBookmark(model: mockCard)

        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    func testAddBookmarkShowsLoadingState() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
            bookmarkResponse: mockCard
        )
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    func testAddBookmarkErrorShowsError() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
        let interactor = LearningLibraryInteractorMock(hasError: true)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.addBookmark(model: mockCard)

        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    // MARK: - Search Tests

    func testSearchTextTriggersGlobalSearch() {
        let mockSearchResults = [
            LearningLibraryCardModel(
                id: "item-1",
                itemId: "course-123",
                name: "Swift Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(searchResponse: mockSearchResults)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        testee.searchText = "Swift"
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(testee.isGlobalSearchActive)
        XCTAssertFalse(testee.isGlobalSearchLoading)
        XCTAssertEqual(testee.globalSearchItems.count, 1)
    }

    func testEmptySearchTextDeactivatesGlobalSearch() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )
        testee.searchText = "Swift"

        testee.searchText = ""

        XCTAssertFalse(testee.isGlobalSearchActive)
    }

    func testSearchWithObjectTypeFilter() {
        let mockSearchResults = [
            LearningLibraryCardModel(
                id: "item-1",
                itemId: "course-123",
                name: "Test Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(searchResponse: mockSearchResults)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        testee.selectedLearningObject = OptionModel(id: "COURSE", name: "Courses")
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(testee.isGlobalSearchActive)
        XCTAssertEqual(testee.globalSearchItems.count, 1)
    }

    func testSearchWithLibraryFilter() {
        let mockSearchResults = [
            LearningLibraryCardModel(
                id: "item-1",
                itemId: "course-123",
                name: "Test Course",
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
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(searchResponse: mockSearchResults)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        testee.selectedLearningLibrary = OptionModel(id: LearningLibraryFilter.bookmarked.rawValue, name: "Bookmarked")
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(testee.isGlobalSearchActive)
        XCTAssertEqual(testee.globalSearchItems.count, 1)
    }

    func testSearchErrorShowsError() {
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(hasError: true)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        testee.searchText = "Swift"
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
        XCTAssertFalse(testee.isGlobalSearchLoading)
    }

    // MARK: - Clear All Tests

    func testClearAllResetsFilters() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )
        testee.searchText = "Swift"
        testee.selectedLearningObject = OptionModel(id: "COURSE", name: "Courses")
        testee.selectedLearningLibrary = OptionModel(id: LearningLibraryFilter.bookmarked.rawValue, name: "Bookmarked")

        testee.clearAll()

        XCTAssertEqual(testee.searchText, "")
        XCTAssertEqual(testee.selectedLearningObject, LearningLibraryObjectType.firstOption)
        XCTAssertEqual(testee.selectedLearningLibrary, LearningLibraryFilter.firstOption)
    }

    // MARK: - Pagination Tests

    func testSeeMoreShowsMoreSections() {
        let sections = (1...10).map { i in
            LearningLibrarySectionModel(
                id: "section-\(i)",
                name: "Section \(i)",
                hasMoreItems: false,
                items: []
            )
        }
        let interactor = LearningLibraryInteractorMock(collections: sections)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )
        testee.fetchCollections()
        let initialCount = testee.filteredSections.count

        testee.seeMore()

        XCTAssertGreaterThan(testee.filteredSections.count, initialCount)
    }

    func testIsSeeMoreVisibleWhenMoreSectionsAvailable() {
        let sections = (1...10).map { i in
            LearningLibrarySectionModel(
                id: "section-\(i)",
                name: "Section \(i)",
                hasMoreItems: false,
                items: []
            )
        }
        let interactor = LearningLibraryInteractorMock(collections: sections)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.fetchCollections()

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    func testIsSeeMoreNotVisibleWhenAllSectionsShown() {
        let sections = [
            LearningLibrarySectionModel(
                id: "section-1",
                name: "Section 1",
                hasMoreItems: false,
                items: []
            )
        ]
        let interactor = LearningLibraryInteractorMock(collections: sections)
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.fetchCollections()

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    // MARK: - Navigation Tests

    func testNavigateToDetailsShowsCorrectView() {
        let section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: false,
            items: []
        )
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.navigateToDetails(section: section, viewController: WeakViewController(UIViewController()))
        wait(for: [router.showExpectation], timeout: 0.1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.LearningLibraryDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    func testNavigateToBookmarksShowsBookmarksView() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.navigateToBookmarks(viewController: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.LearningLibraryDetailsView>
        XCTAssertNotNil(presentedVC)
    }

    func testShowEnrollConfirmationShowsModal() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        testee.showEnrollConfirmation(model: mockCard, viewController: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.EnrollConfirmationView>
        XCTAssertNotNil(presentedVC)
    }

    // MARK: - Initial State Tests

    func testInitialStateShowsLoader() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        XCTAssertTrue(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasLibrary)
        XCTAssertFalse(testee.isErrorVisible)
        XCTAssertFalse(testee.isGlobalSearchActive)
        XCTAssertFalse(testee.isGlobalSearchLoading)
    }

    func testInitialSearchTextIsEmpty() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.searchText, "")
    }

    func testInitialFiltersAreFirstOptions() {
        let interactor = LearningLibraryInteractorMock()
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.selectedLearningObject, LearningLibraryObjectType.firstOption)
        XCTAssertEqual(testee.selectedLearningLibrary, LearningLibraryFilter.firstOption)
    }

    // MARK: - Update Item Tests

    func testUpdateWithCollectionUpdatesGlobalSearchItems() {
        let initialCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
        let updatedCard = LearningLibraryCardModel(
            id: "item-1",
            itemId: "course-123",
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
        let mockSection = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: false,
            items: []
        )
        let interactor = LearningLibraryInteractorMock(
            collections: [mockSection],
            searchResponse: [initialCard],
            bookmarkResponse: updatedCard
        )
        let testee = LearningLibraryViewModel(
            router: router,
            interactor: interactor,
            scheduler: .immediate
        )
        testee.searchText = "Test"
        testee.fetchCollections()

        testee.addBookmark(model: initialCard)

        XCTAssertTrue(testee.hasLibrary)
    }
}
