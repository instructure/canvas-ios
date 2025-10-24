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
@testable import Horizon
@testable import Core

final class AnnouncementsListWidgetViewModelTests: HorizonTestCase {

    func testInitializationFetchesAndFiltersAnnouncements() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let unreadAnnouncement = NotificationModel(id: "1", type: .announcement, isRead: false)
        let readAnnouncement = NotificationModel(id: "2", type: .announcement, isRead: true)
        let globalAnnouncement = NotificationModel(id: "3", type: .announcement, isRead: false, isGlobalNotification: true)
        let otherNotification = NotificationModel(id: "4", type: .score, isRead: false)
        let expiredNotification = NotificationModel(
            id: "4",
            type: .announcement,
            isRead: false,
            date: Calendar.current.date(byAdding: .day, value: -16, to: Date())
        )

        interactor.mockedNotifications = [unreadAnnouncement, readAnnouncement, globalAnnouncement, otherNotification, expiredNotification, expiredNotification]
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.announcements.count, 2)
        XCTAssertTrue(testee.announcements.contains(where: { $0.id == "1" }))
        XCTAssertTrue(testee.announcements.contains(where: { $0.id == "3" }))
        XCTAssertEqual(testee.currentAnnouncement.id, "1")
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertTrue(testee.isNavigationButtonVisiable)
    }

    func testFetchAnnouncementsWithEmptyResponse() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        interactor.mockedNotifications = []
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertTrue(testee.announcements.isEmpty)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isNavigationButtonVisiable)
    }

    func testFetchAnnouncementsOnErrorReturnsEmptyData() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: true)
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Then
        XCTAssertEqual(testee.state, .empty)
        XCTAssertTrue(testee.announcements.isEmpty)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)
    }

    func testFetchAnnouncementsWithIgnoreCacheTrue() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let unreadAnnouncement = NotificationModel(id: "1", type: .announcement, isRead: false)
        interactor.mockedNotifications = [unreadAnnouncement]
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // When - force reload with new data
        let updatedAnnouncement = NotificationModel(id: "2", type: .announcement, isRead: false)
        interactor.mockedNotifications = [updatedAnnouncement]

        // Initially in data state with first announcement
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.currentAnnouncement.id, "1")

        var completionCalled = false
        testee.fetchAnnouncements(ignoreCache: true) {
            completionCalled = true
        }

        // Then
        XCTAssertTrue(completionCalled)
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.currentAnnouncement.id, "2")
    }

    // MARK: - Navigation

    func testGoNextAnnouncement() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let announcement1 = NotificationModel(id: "1", type: .announcement, isRead: false)
        let announcement2 = NotificationModel(id: "2", type: .announcement, isRead: false)
        let announcement3 = NotificationModel(id: "3", type: .announcement, isRead: false)
        interactor.mockedNotifications = [announcement1, announcement2, announcement3]
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Initially at first announcement
        XCTAssertEqual(testee.currentAnnouncement.id, "1")
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        // When going to next announcement
        testee.goNextAnnouncement()

        // Then
        XCTAssertEqual(testee.currentAnnouncement.id, "2")
        XCTAssertEqual(testee.currentInex, 1)
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        // When going to last announcement
        testee.goNextAnnouncement()

        // Then
        XCTAssertEqual(testee.currentAnnouncement.id, "3")
        XCTAssertEqual(testee.currentInex, 2)
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)

        // When trying to go past the end
        testee.goNextAnnouncement()

        // Then - should stay at the last announcement
        XCTAssertEqual(testee.currentAnnouncement.id, "3")
        XCTAssertEqual(testee.currentInex, 2)
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)
    }

    func testGoPreviousAnnouncement() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let announcement1 = NotificationModel(id: "1", type: .announcement, isRead: false)
        let announcement2 = NotificationModel(id: "2", type: .announcement, isRead: false)
        let announcement3 = NotificationModel(id: "3", type: .announcement, isRead: false)
        interactor.mockedNotifications = [announcement1, announcement2, announcement3]
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Navigate to last announcement
        testee.goNextAnnouncement()
        testee.goNextAnnouncement()

        // Verify we're at the last announcement
        XCTAssertEqual(testee.currentAnnouncement.id, "3")
        XCTAssertEqual(testee.currentInex, 2)
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)

        // When going to previous announcement
        testee.goPreviousAnnouncement()

        // Then
        XCTAssertEqual(testee.currentAnnouncement.id, "2")
        XCTAssertEqual(testee.currentInex, 1)
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        // When going to first announcement
        testee.goPreviousAnnouncement()

        // Then
        XCTAssertEqual(testee.currentAnnouncement.id, "1")
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        // When trying to go before the beginning
        testee.goPreviousAnnouncement()

        // Then - should stay at the first announcement
        XCTAssertEqual(testee.currentAnnouncement.id, "1")
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)
    }

    func testNavigationWithEmptyAnnouncements() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        interactor.mockedNotifications = []
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Initial state
        XCTAssertEqual(testee.currentAnnouncement, NotificationModel.mock)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)

        // When
        testee.goNextAnnouncement()

        // Then - no change
        XCTAssertEqual(testee.currentAnnouncement, NotificationModel.mock)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)

        // When
        testee.goPreviousAnnouncement()

        // Then - no change
        XCTAssertEqual(testee.currentAnnouncement, NotificationModel.mock)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)
    }

    func testNavigateToAnnouncementRoutesToMessageDetails() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        let announcement = NotificationModel(id: "1", type: .announcement, announcementId: "ann-1")
        let viewController = WeakViewController(UIViewController())

        // When
        testee.navigateToAnnouncement(announcement: announcement, viewController: viewController)

        // Then
        wait(for: [router.showExpectation], timeout: 1)
        let messageDetailsVC = router.lastViewController as? CoreHostingController<HMessageDetailsView>
        XCTAssertNotNil(messageDetailsVC)
    }

    func testHiedNavigationButtonWithOneAnnouncement() {
        // Given

        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let announcement1 = NotificationModel(id: "1", type: .announcement, isRead: false)
        interactor.mockedNotifications = [announcement1]
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Then
        XCTAssertFalse(testee.isNavigationButtonVisiable)
    }

    func testMarkAsRead() {
        // Given
        let interactor = NotificationInteractorMock()
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)
        let viewController = WeakViewController(UIViewController())
        let globalAnnouncement = NotificationModel(id: "3", type: .announcement, isRead: true, isGlobalNotification: true)
        // When
        testee.navigateToAnnouncement(announcement: globalAnnouncement, viewController: viewController)
        // Then
        XCTAssertEqual(testee.announcements.count, 1)
    }
}

// MARK: - Mock Extensions

private extension NotificationModel {
    init(
        id: String,
        type: NotificationType,
        isRead: Bool = false,
        isGlobalNotification: Bool = false,
        announcementId: String? = nil,
        date: Date? = Date()
    ) {
        self.init(
            id: id,
            title: "Title \(id)",
            date: date,
            isRead: isRead,
            courseName: "Course",
            courseID: "1",
            enrollmentID: "1",
            isScoreAnnouncement: false,
            type: type,
            announcementId: announcementId,
            assignmentURL: nil,
            htmlURL: nil,
            isGlobalNotification: isGlobalNotification
        )
    }
}
