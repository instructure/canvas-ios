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
import Combine
import CombineSchedulers
@testable import Horizon
@testable import Core

final class AnnouncementsListWidgetViewModelTests: HorizonTestCase {
    private var interactor: AnnouncementInteractorMock!

    override func setUp() {
        super.setUp()
        interactor = AnnouncementInteractorMock()
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationFetchesAnnouncementsAndSetsDataState() {
        // Given
        let unreadAnnouncements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            ),
            AnnouncementModel(
                id: "2",
                title: "Announcement 2",
                content: "Content 2",
                date: Date(),
                isRead: false,
                isGlobal: true
            )
        ]
        interactor.mockedAnnouncements = unreadAnnouncements

        // When
        let testee = createViewModel()

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.announcements.count, 2)
        XCTAssertEqual(testee.announcements[0].id, "1")
        XCTAssertEqual(testee.announcements[1].id, "2")
        XCTAssertTrue(testee.isCounterViewVisible)
    }

    func testInitializationWithEmptyAnnouncementsSetsEmptyState() {
        // Given
        interactor.mockedAnnouncements = []

        // When
        let testee = createViewModel()

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.announcements.count, 0)
        XCTAssertFalse(testee.isCounterViewVisible)
    }

    func testInitializationFilterOutReadAnnouncements() {
        // Given
        let announcements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            ),
            AnnouncementModel(
                id: "2",
                title: "Announcement 2",
                content: "Content 2",
                date: Date(),
                isRead: true,
                isGlobal: false
            ),
            AnnouncementModel(
                id: "3",
                title: "Announcement 3",
                content: "Content 3",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]
        interactor.mockedAnnouncements = announcements

        // When
        let testee = createViewModel()

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.announcements.count, 2)
        XCTAssertEqual(testee.announcements[0].id, "1")
        XCTAssertEqual(testee.announcements[1].id, "3")
    }

    // MARK: - Counter View Visibility Tests

    func testCounterViewVisibleWhenMultipleAnnouncements() {
        // Given
        let announcements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            ),
            AnnouncementModel(
                id: "2",
                title: "Announcement 2",
                content: "Content 2",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]
        interactor.mockedAnnouncements = announcements

        // When
        let testee = createViewModel()

        // Then
        XCTAssertTrue(testee.isCounterViewVisible)
    }

    func testCounterViewHiddenWhenSingleAnnouncement() {
        // Given
        let announcements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]
        interactor.mockedAnnouncements = announcements

        // When
        let testee = createViewModel()

        // Then
        XCTAssertFalse(testee.isCounterViewVisible)
    }

    // MARK: - Fetch Announcements Tests

    func testFetchAnnouncementsWithIgnoreCacheTrue() {
        // Given
        let initialAnnouncements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]
        interactor.mockedAnnouncements = initialAnnouncements
        let testee = createViewModel()
        XCTAssertEqual(testee.announcements.count, 1)

        let newAnnouncements = [
            AnnouncementModel(
                id: "2",
                title: "Announcement 2",
                content: "Content 2",
                date: Date(),
                isRead: false,
                isGlobal: false
            ),
            AnnouncementModel(
                id: "3",
                title: "Announcement 3",
                content: "Content 3",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]
        interactor.mockedAnnouncements = newAnnouncements

        // When
        testee.fetchAnnouncements(ignoreCache: true)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.announcements.count, 2)
        XCTAssertEqual(testee.announcements[0].id, "2")
        XCTAssertEqual(testee.announcements[1].id, "3")
    }

    func testFetchAnnouncementsResetsCurrentCardIndex() {
        // Given
        interactor.mockedAnnouncements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            ),
            AnnouncementModel(
                id: "2",
                title: "Announcement 2",
                content: "Content 2",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]
        let testee = createViewModel()
        testee.currentCardIndex = 1

        // When
        testee.fetchAnnouncements(ignoreCache: true)

        // Then
        XCTAssertEqual(testee.currentCardIndex, 0)
    }

    func testFetchAnnouncementsCallsCompletion() {
        // Given
        interactor.mockedAnnouncements = []
        let testee = createViewModel()
        var completionCalled = false

        // When
        testee.fetchAnnouncements(ignoreCache: false) {
            completionCalled = true
        }

        // Then
        XCTAssertTrue(completionCalled)
    }

    // MARK: - Navigation Tests

    func testNavigateToAnnouncementCallsRouter() {
        // Given
        let announcement = AnnouncementModel(
            id: "1",
            title: "Test Announcement",
            content: "Test Content",
            courseID: "course-1",
            courseName: "iOS Development",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        interactor.mockedAnnouncements = [announcement]
        let testee = createViewModel()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateToAnnouncement(announcement: announcement, viewController: viewController)

        // Then
        XCTAssertEqual(router.showExpectation.expectedFulfillmentCount, 1)
        wait(for: [router.showExpectation], timeout: 1)
    }

    func testNavigateToAnnouncementMarksAsRead() {
        // Given
        let announcement = AnnouncementModel(
            id: "1",
            title: "Test Announcement",
            content: "Test Content",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        let announcement2 = AnnouncementModel(
            id: "2",
            title: "Test Announcement 2",
            content: "Test Content 2",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        interactor.mockedAnnouncements = [announcement, announcement2]
        let testee = createViewModel(scheduler: .immediate)
        XCTAssertEqual(testee.announcements.count, 2)

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateToAnnouncement(announcement: announcement, viewController: viewController)

        // Then
        XCTAssertEqual(testee.announcements.count, 1)
        XCTAssertEqual(testee.announcements[0].id, "2")
    }

    // MARK: - Mark As Read Tests

    func testMarkAsReadUpdatesAnnouncementsList() {
        // Given
        let announcement1 = AnnouncementModel(
            id: "1",
            title: "Announcement 1",
            content: "Content 1",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        let announcement2 = AnnouncementModel(
            id: "2",
            title: "Announcement 2",
            content: "Content 2",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        interactor.mockedAnnouncements = [announcement1, announcement2]
        let testee = createViewModel(scheduler: .immediate)
        XCTAssertEqual(testee.announcements.count, 2)

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.navigateToAnnouncement(announcement: announcement1, viewController: viewController)

        // Then
        XCTAssertEqual(testee.announcements.count, 1)
        XCTAssertEqual(testee.announcements[0].id, "2")
    }

    func testMarkAsReadUpdatesStateToEmptyWhenLastAnnouncement() {
        // Given
        let announcement = AnnouncementModel(
            id: "1",
            title: "Announcement 1",
            content: "Content 1",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        interactor.mockedAnnouncements = [announcement]
        let testee = createViewModel(scheduler: .immediate)
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.announcements.count, 1)

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        interactor.mockedAnnouncements = []

        // When
        testee.navigateToAnnouncement(announcement: announcement, viewController: viewController)

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.announcements.count, 0)
    }

    func testMarkAsReadUpdatesCounterViewVisibility() {
        // Given
        let announcement1 = AnnouncementModel(
            id: "1",
            title: "Announcement 1",
            content: "Content 1",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        let announcement2 = AnnouncementModel(
            id: "2",
            title: "Announcement 2",
            content: "Content 2",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        interactor.mockedAnnouncements = [announcement1, announcement2]
        let testee = createViewModel(scheduler: .immediate)
        XCTAssertTrue(testee.isCounterViewVisible)

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        interactor.mockedAnnouncements = [announcement2]

        // When
        testee.navigateToAnnouncement(announcement: announcement1, viewController: viewController)

        // Then
        XCTAssertFalse(testee.isCounterViewVisible)
    }

    // MARK: - Current Card Index Tests

    func testCurrentCardIndexInitializedToZero() {
        // Given
        interactor.mockedAnnouncements = [
            AnnouncementModel(
                id: "1",
                title: "Announcement 1",
                content: "Content 1",
                date: Date(),
                isRead: false,
                isGlobal: false
            )
        ]

        // When
        let testee = createViewModel()

        // Then
        XCTAssertEqual(testee.currentCardIndex, 0)
    }

    // MARK: - Helper Methods

    private func createViewModel(scheduler: AnySchedulerOf<DispatchQueue> = .immediate) -> AnnouncementsListWidgetViewModel {
        AnnouncementsListWidgetViewModel(
            interactor: interactor,
            router: router,
            scheduler: scheduler
        )
    }
}
