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

final class LearningLibraryDetailsViewModelTests: HorizonTestCase {

    // MARK: - Fetch Data Tests (Details Page)

    func testFetchDataForDetailsPageLoadsCollectionItems() {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Swift Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            ),
            LearningLibraryCardModel(
                id: "item-2",
                courseID: "course-456",
                name: "SwiftUI Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "90",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 3,
                isEnrolled: true
            )
        ]
        let interactor = LearningLibraryInteractorMock(collectionItems: mockItems)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasItems)
        XCTAssertEqual(testee.filteredItems.count, 2)
    }

    func testFetchDataForDetailsPageWithEmptyResponse() {
        let interactor = LearningLibraryInteractorMock(collectionItems: [])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasItems)
        XCTAssertEqual(testee.filteredItems.count, 0)
    }

    func testFetchDataForDetailsPageWithError() {
        let interactor = LearningLibraryInteractorMock(hasError: true)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
    }

    // MARK: - Fetch Data Tests (Bookmarks Page)

    func testFetchDataForBookmarksPageLoadsBookmarkedItems() {
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
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasItems)
        XCTAssertEqual(testee.filteredItems.count, 1)
    }

    func testFetchDataForBookmarksPageWithEmptyResponse() {
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: [])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasItems)
    }

    func testFetchDataCallsCompletion() {
        let interactor = LearningLibraryInteractorMock(bookmarkedItems: [])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
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
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        await testee.refresh()

        XCTAssertFalse(testee.isLoaderVisible)
        XCTAssertTrue(testee.hasItems)
    }

    // MARK: - Filter Tests

    func testFilterBySearchText() {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Swift Programming",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            ),
            LearningLibraryCardModel(
                id: "item-2",
                courseID: "course-456",
                name: "Python Basics",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "90",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 3,
                isEnrolled: false
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(collectionItems: mockItems)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        testee.fetchData()

        testee.searchText = "Swift"
        scheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredItems.count, 1)
        XCTAssertEqual(testee.filteredItems.first?.name, "Swift Programming")
    }

    func testFilterByLearningObjectType() {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Swift Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            ),
            LearningLibraryCardModel(
                id: "item-2",
                courseID: "page-456",
                name: "Resource Page",
                imageURL: nil,
                itemType: .page,
                estimatedTime: nil,
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: nil,
                isEnrolled: false
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(collectionItems: mockItems)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        testee.fetchData()

        testee.selectedLearningObject = OptionModel(id: "COURSE", name: "Courses")
        scheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredItems.count, 1)
        XCTAssertEqual(testee.filteredItems.first?.itemType, .course)
    }

    func testFilterByBookmarkedOnly() {
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
            ),
            LearningLibraryCardModel(
                id: "item-2",
                courseID: "course-456",
                name: "Regular Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "90",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 3,
                isEnrolled: false
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(collectionItems: mockItems)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        testee.fetchData()

        testee.selectedLearningLibrary = OptionModel(id: LearningLibraryFilter.bookmarked.rawValue, name: "Bookmarked")
        scheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredItems.count, 1)
        XCTAssertTrue(testee.filteredItems.first?.isBookmarked ?? false)
    }

    func testFilterByCompletedOnly() {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Completed Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: true,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: true
            ),
            LearningLibraryCardModel(
                id: "item-2",
                courseID: "course-456",
                name: "In Progress Course",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "90",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 3,
                isEnrolled: true
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(collectionItems: mockItems)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        testee.fetchData()

        testee.selectedLearningLibrary = OptionModel(id: LearningLibraryFilter.completed.rawValue, name: "Completed")
        scheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredItems.count, 1)
        XCTAssertTrue(testee.filteredItems.first?.isCompleted ?? false)
    }

    func testFilterCombinesSearchTextAndFilters() {
        let mockItems = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Swift Programming",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "120",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 5,
                isEnrolled: false
            ),
            LearningLibraryCardModel(
                id: "item-2",
                courseID: "course-456",
                name: "Swift Advanced",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "90",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 3,
                isEnrolled: false
            )
        ]
        let scheduler = DispatchQueue.test
        let interactor = LearningLibraryInteractorMock(collectionItems: mockItems)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        testee.fetchData()

        testee.searchText = "Swift"
        testee.selectedLearningLibrary = OptionModel(id: LearningLibraryFilter.bookmarked.rawValue, name: "Bookmarked")
        scheduler.advance(by: .milliseconds(200))

        XCTAssertEqual(testee.filteredItems.count, 1)
        XCTAssertEqual(testee.filteredItems.first?.name, "Swift Programming")
    }

    // MARK: - Clear All Tests

    func testClearAllResetsFilters() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
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

    func testIsClearButtonVisibleWithSearchText() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        testee.searchText = "Swift"

        XCTAssertTrue(testee.isClearButtonVisible)
    }

    func testIsClearButtonVisibleWithObjectFilter() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        testee.selectedLearningObject = OptionModel(id: "COURSE", name: "Courses")

        XCTAssertTrue(testee.isClearButtonVisible)
    }

    func testIsClearButtonNotVisibleByDefault() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        XCTAssertFalse(testee.isClearButtonVisible)
    }

    // MARK: - Bookmark Tests

    func testAddBookmarkInDetailsPageUpdatesItem() {
        let mockCard = LearningLibraryCardModel(
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
        let updatedCard = LearningLibraryCardModel(
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
        let interactor = LearningLibraryInteractorMock(
            collectionItems: [mockCard],
            bookmarkResponse: updatedCard
        )
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )
        testee.fetchData()

        testee.addBookmark(model: mockCard)

        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    func testAddBookmarkInBookmarksPageRemovesItem() {
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
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )
        testee.fetchData()
        XCTAssertEqual(testee.filteredItems.count, 1)

        testee.addBookmark(model: mockCard)

        XCTAssertEqual(testee.filteredItems.count, 0)
        XCTAssertFalse(testee.hasItems)
    }

    func testAddBookmarkSendsDidSendEvent() {
        let mockCard = LearningLibraryCardModel(
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
        let interactor = LearningLibraryInteractorMock(bookmarkResponse: mockCard)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let expectation = expectation(description: "Event sent")
        var cancellables = Set<AnyCancellable>()
        didSendEvent.sink { _ in expectation.fulfill() }.store(in: &cancellables)

        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.addBookmark(model: mockCard)

        wait(for: [expectation], timeout: 0.1)
    }

    func testAddBookmarkErrorShowsError() {
        let mockCard = LearningLibraryCardModel(
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
        let interactor = LearningLibraryInteractorMock(hasError: true)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.addBookmark(model: mockCard)

        XCTAssertTrue(testee.isErrorVisible)
        XCTAssertFalse(testee.errorMessage.isEmpty)
        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    // MARK: - Enroll Confirmation Tests

    func testShowEnrollConfirmationShowsModal() {
        let mockCard = LearningLibraryCardModel(
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
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.showEnrollConfirmation(model: mockCard, viewController: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.EnrollConfirmationView>
        XCTAssertNotNil(presentedVC)
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
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            )
        }
        let interactor = LearningLibraryInteractorMock(collectionItems: items)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
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
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            )
        }
        let interactor = LearningLibraryInteractorMock(collectionItems: items)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertTrue(testee.isSeeMoreVisible)
    }

    func testIsSeeMoreNotVisibleWhenAllItemsShown() {
        let items = [
            LearningLibraryCardModel(
                id: "item-1",
                courseID: "course-123",
                name: "Course 1",
                imageURL: nil,
                itemType: .course,
                estimatedTime: "60",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 5,
                isEnrolled: false
            )
        ]
        let interactor = LearningLibraryInteractorMock(collectionItems: items)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .details(id: "collection-123", name: "Featured"),
            scheduler: .immediate
        )

        testee.fetchData()

        XCTAssertFalse(testee.isSeeMoreVisible)
    }

    // MARK: - Navigation Tests

    func testPopDismissesViewController() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        testee.pop(viewController: WeakViewController(UIViewController()))

        wait(for: [router.dismissExpectation], timeout: 0.1)
    }

    // MARK: - Page Type Tests

    func testPageTypeDetailsTitleMatchesName() {
        let pageType = LearningLibraryDetailsViewModel.PageType.details(id: "123", name: "My Collection")
        XCTAssertEqual(pageType.title, "My Collection")
        XCTAssertFalse(pageType.isBookmarked)
    }

    func testPageTypeBookmarksTitle() {
        let pageType = LearningLibraryDetailsViewModel.PageType.bookmarks
        XCTAssertEqual(pageType.title, "Bookmarks")
        XCTAssertTrue(pageType.isBookmarked)
    }

    func testPageTypeBookmarksEmptyStateTitle() {
        let pageType = LearningLibraryDetailsViewModel.PageType.bookmarks
        XCTAssertFalse(pageType.emptyStateTitle.isEmpty)
    }

    // MARK: - Initial State Tests

    func testInitialStateShowsLoader() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        XCTAssertTrue(testee.isLoaderVisible)
        XCTAssertFalse(testee.hasItems)
        XCTAssertFalse(testee.isErrorVisible)
    }

    func testInitialSearchTextIsEmpty() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.searchText, "")
    }

    func testInitialFiltersAreFirstOptions() {
        let interactor = LearningLibraryInteractorMock()
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryDetailsViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            pageType: .bookmarks,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.selectedLearningObject, LearningLibraryObjectType.firstOption)
        XCTAssertEqual(testee.selectedLearningLibrary, LearningLibraryFilter.firstOption)
    }
}
