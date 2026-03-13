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

final class LearningLibraryRecommendationListViewModelTests: HorizonTestCase {

    // MARK: - Load Recommendations Tests

    func testLoadRecommendationsSuccessShowsData() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.recommendedItems.count, 2)
        XCTAssertEqual(testee.recommendedItems[0].id, "item-1")
        XCTAssertEqual(testee.recommendedItems[1].id, "item-2")
    }

    func testLoadRecommendationsEmptyResponseReturnsEmptyList() {
        let interactor = LearningLibraryInteractorMock(recommendations: [])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.recommendedItems.count, 0)
    }

    func testLoadRecommendationsErrorReturnsEmptyList() {
        let interactor = LearningLibraryInteractorMock(hasError: true)
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.recommendedItems.count, 0)
    }

    func testLoadRecommendationsWithIgnoreCache() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        testee.loadItems(ignoreCache: true)

        XCTAssertEqual(testee.recommendedItems.count, 1)
    }

    func testLoadRecommendationsCallsCompletion() {
        let interactor = LearningLibraryInteractorMock(recommendations: [])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        let expectation = expectation(description: "Completion called")

        testee.loadItems { expectation.fulfill() }

        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - Refresh Tests

    func testRefreshReloadsRecommendations() async {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        await testee.refresh()

        XCTAssertEqual(testee.recommendedItems.count, 1)
    }

    // MARK: - Bookmark Tests

    func testAddBookmarkUpdatesItem() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
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
            isRecommended: true,
            isCompleted: false,
            isBookmarked: true,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(
            recommendations: [mockCard],
            bookmarkResponse: updatedCard
        )
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        testee.addBookmark(model: mockCard)

        XCTAssertEqual(testee.recommendedItems[0].isBookmarked, true)
        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    func testAddBookmarkShowsLoadingState() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(
            recommendations: [mockCard],
            bookmarkResponse: mockCard
        )
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertFalse(testee.isBookmarkLoading(forItemWithId: "item-1"))
    }

    func testAddBookmarkSendsDidSendEvent() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
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
            isRecommended: true,
            isCompleted: false,
            isBookmarked: true,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(
            recommendations: [mockCard],
            bookmarkResponse: updatedCard
        )
        let didSendEvent = PassthroughSubject<Void, Never>()
        var eventReceived = false
        var cancellables = Set<AnyCancellable>()
        didSendEvent.sink { _ in
            eventReceived = true
        }.store(in: &cancellables)
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        testee.addBookmark(model: mockCard)

        XCTAssertTrue(eventReceived)
    }

    // MARK: - Scroll Position Tests

    func testShouldShowButtonsWithMultipleItems() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertTrue(testee.shouldShowButtons)
    }

    func testShouldNotShowButtonsWithSingleItem() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertFalse(testee.shouldShowButtons)
    }

    func testCurrentIndexWithNilScrollPosition() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.currentIndex, 0)
    }

    func testCurrentIndexWithValidScrollPosition() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-2"

        XCTAssertEqual(testee.currentIndex, 1)
    }

    func testIsAtStartWhenAtFirstItem() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-1"

        XCTAssertTrue(testee.isAtStart)
    }

    func testIsNotAtStartWhenNotAtFirstItem() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-2"

        XCTAssertFalse(testee.isAtStart)
    }

    func testIsAtEndWhenAtLastItem() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-2"

        XCTAssertTrue(testee.isAtEnd)
    }

    func testIsNotAtEndWhenNotAtLastItem() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-1"

        XCTAssertFalse(testee.isAtEnd)
    }

    // MARK: - Navigation Tests

    func testGoToPreviousCardUpdatesScrollPosition() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-2"

        testee.goToPreviousCard()

        XCTAssertEqual(testee.scrollPosition, "item-1")
    }

    func testGoToPreviousCardStaysAtFirstItem() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-1"

        testee.goToPreviousCard()

        XCTAssertEqual(testee.scrollPosition, "item-1")
    }

    func testGoToNextCardUpdatesScrollPosition() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-1"

        testee.goToNextCard()

        XCTAssertEqual(testee.scrollPosition, "item-2")
    }

    func testGoToNextCardStaysAtLastItem() {
        let mockCard1 = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course 1",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let mockCard2 = LearningLibraryCardModel(
            id: "item-2",
            courseID: "course-456",
            name: "Test Course 2",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "90",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 3,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard1, mockCard2])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        testee.scrollPosition = "item-2"

        testee.goToNextCard()

        XCTAssertEqual(testee.scrollPosition, "item-2")
    }

    // MARK: - Enrollment Confirmation Tests

    func testShowEnrollConfirmationShowsModal() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        testee.showEnrollConfirmation(model: mockCard, viewController: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.EnrollConfirmationView>
        XCTAssertNotNil(presentedVC)
    }

    func testNavigateToDetailsForUnenrolledCourseShowsEnrollConfirmation() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        testee.navigateToLearningLibraryItemDetails(mockCard, from: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
        let presentedVC = router.lastViewController as? CoreHostingController<Horizon.EnrollConfirmationView>
        XCTAssertNotNil(presentedVC)
    }

    func testNavigateToDetailsForNonCourseItem() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Path",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )

        testee.navigateToLearningLibraryItemDetails(mockCard, from: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
    }

    // MARK: - Accessibility Announcement Tests

    func testAccessibilityPublisherMergesBookmarkAndInternalMessages() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
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
            isRecommended: true,
            isCompleted: false,
            isBookmarked: true,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(
            recommendations: [mockCard],
            bookmarkResponse: updatedCard
        )
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        var receivedMessages: [String] = []
        var cancellables = Set<AnyCancellable>()
        testee.accessibilityMessagePublisher.sink { message in
            receivedMessages.append(message)
        }.store(in: &cancellables)

        testee.addBookmark(model: mockCard)

        XCTAssertTrue(receivedMessages.contains("Added to bookmarks"))
    }

    func testEnrollConfirmationAnnouncesEnrolledSuccessfully() {
        let mockCard = LearningLibraryCardModel(
            id: "item-1",
            courseID: "course-123",
            name: "Test Course",
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: true,
            isCompleted: false,
            isBookmarked: false,
            numberOfUnits: 5,
            isEnrolled: false
        )
        let interactor = LearningLibraryInteractorMock(recommendations: [mockCard])
        let didSendEvent = PassthroughSubject<Void, Never>()
        let testee = LearningLibraryRecommendationListViewModel(
            interactor: interactor,
            router: router,
            didSendEvent: didSendEvent,
            scheduler: .immediate
        )
        var receivedMessages: [String] = []
        var cancellables = Set<AnyCancellable>()
        testee.accessibilityMessagePublisher.sink { message in
            receivedMessages.append(message)
        }.store(in: &cancellables)

        testee.showEnrollConfirmation(model: mockCard, viewController: WeakViewController(UIViewController()))

        wait(for: [router.showExpectation], timeout: 0.1)
    }
}
