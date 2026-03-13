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
import XCTest
import Combine
import CombineSchedulers

final class BookmarkManagerTests: XCTestCase {
    var subscriptions: Set<AnyCancellable>!
    var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        subscriptions = Set<AnyCancellable>()
        testScheduler = DispatchQueue.test
    }

    override func tearDown() {
        subscriptions = nil
        testScheduler = nil
        super.tearDown()
    }

    func testToggleBookmarkSetsLoadingStateTrue() {
        let manager = BookmarkManager()
        let item = makeMockItem(id: "item-1", isBookmarked: false)
        let interactor = LearningLibraryInteractorMock(
            bookmarkResponse: makeMockItem(id: "item-1", isBookmarked: true)
        )

        XCTAssertFalse(manager.isLoading(itemId: "item-1"))

        let expectation = self.expectation(description: "Toggle bookmark")
        manager.toggleBookmark(item, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        XCTAssertTrue(manager.isLoading(itemId: "item-1"))

        testScheduler.advance()
        waitForExpectations(timeout: 1)
    }

    func testToggleBookmarkSuccessClearsLoadingState() {
        let manager = BookmarkManager()
        let item = makeMockItem(id: "item-1", isBookmarked: false)
        let interactor = LearningLibraryInteractorMock(
            bookmarkResponse: makeMockItem(id: "item-1", isBookmarked: true)
        )

        let expectation = self.expectation(description: "Toggle bookmark")
        manager.toggleBookmark(item, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testScheduler.advance()
        waitForExpectations(timeout: 1)

        XCTAssertFalse(manager.isLoading(itemId: "item-1"))
    }

    func testToggleBookmarkFailureClearsLoadingState() {
        let manager = BookmarkManager()
        let item = makeMockItem(id: "item-1", isBookmarked: false)
        let interactor = LearningLibraryInteractorMock(hasError: true)

        let expectation = self.expectation(description: "Toggle bookmark")
        manager.toggleBookmark(item, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testScheduler.advance()
        waitForExpectations(timeout: 1)

        XCTAssertFalse(manager.isLoading(itemId: "item-1"))
    }

    func testToggleBookmarkTogglesBookmarkedState() {
        let manager = BookmarkManager()
        let item = makeMockItem(id: "item-1", isBookmarked: false)
        let interactor = LearningLibraryInteractorMock(
            bookmarkResponse: makeMockItem(id: "item-1", isBookmarked: true)
        )

        let expectation = self.expectation(description: "Toggle bookmark")
        var receivedItem: LearningLibraryCardModel?

        manager.toggleBookmark(item, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { updatedItem in
                    receivedItem = updatedItem
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance()
        waitForExpectations(timeout: 1)

        XCTAssertNotNil(receivedItem)
        XCTAssertTrue(receivedItem?.isBookmarked ?? false)
    }

    func testToggleBookmarkSendsAccessibilityMessageForAdding() {
        let manager = BookmarkManager()
        let item = makeMockItem(id: "item-1", isBookmarked: false)
        let interactor = LearningLibraryInteractorMock(
            bookmarkResponse: makeMockItem(id: "item-1", isBookmarked: true)
        )

        let expectation = self.expectation(description: "Accessibility message")
        var receivedMessage: String?

        manager.accessibilityPublisher
            .sink { message in
                receivedMessage = message
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        manager.toggleBookmark(item, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testScheduler.advance()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(receivedMessage, String(localized: "Added to bookmarks"))
    }

    func testToggleBookmarkSendsAccessibilityMessageForRemoving() {
        let manager = BookmarkManager()
        let item = makeMockItem(id: "item-1", isBookmarked: true)
        let interactor = LearningLibraryInteractorMock(
            bookmarkResponse: makeMockItem(id: "item-1", isBookmarked: false)
        )

        let expectation = self.expectation(description: "Accessibility message")
        var receivedMessage: String?

        manager.accessibilityPublisher
            .sink { message in
                receivedMessage = message
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        manager.toggleBookmark(item, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testScheduler.advance()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(receivedMessage, String(localized: "Removed from bookmarks"))
    }

    func testMultipleSimultaneousBookmarksTrackLoadingIndependently() {
        let manager = BookmarkManager()
        let item1 = makeMockItem(id: "item-1", isBookmarked: false)
        let item2 = makeMockItem(id: "item-2", isBookmarked: false)
        let interactor = LearningLibraryInteractorMock(
            bookmarkResponse: makeMockItem(id: "item-1", isBookmarked: true)
        )

        manager.toggleBookmark(item1, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        manager.toggleBookmark(item2, using: interactor, scheduler: testScheduler.eraseToAnyScheduler())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        XCTAssertTrue(manager.isLoading(itemId: "item-1"))
        XCTAssertTrue(manager.isLoading(itemId: "item-2"))

        testScheduler.advance()

        XCTAssertFalse(manager.isLoading(itemId: "item-1"))
        XCTAssertFalse(manager.isLoading(itemId: "item-2"))
    }

    func testIsLoadingReturnsFalseForUnknownItem() {
        let manager = BookmarkManager()
        XCTAssertFalse(manager.isLoading(itemId: "unknown-id"))
    }

    private func makeMockItem(id: String, isBookmarked: Bool) -> LearningLibraryCardModel {
        LearningLibraryCardModel(
            id: id,
            courseID: "course-1",
            name: "Test Item",
            imageURL: nil,
            itemType: .course,
            estimatedTime: nil,
            isRecommended: false,
            isCompleted: false,
            isBookmarked: isBookmarked,
            numberOfUnits: nil,
            isEnrolled: true,
            isInProgress: false,
            courseEnrollmentId: nil,
            libraryId: "library-1",
            moduleItemID: nil,
            canvasUrl: nil
        )
    }
}
