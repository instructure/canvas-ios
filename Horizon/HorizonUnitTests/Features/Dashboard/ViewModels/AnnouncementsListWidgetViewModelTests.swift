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
@testable import Horizon
@testable import Core

final class AnnouncementsListWidgetViewModelTests: HorizonTestCase {

    func testInitializationFetchesAndFiltersAnnouncements() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let unreadAnnouncement = NotificationModel(id: "1", type: .announcement, isRead: false)
        let readAnnouncement = NotificationModel(id: "2", type: .announcement, isRead: true)
        let globalAnnouncement = NotificationModel(id: "3", type: .announcement, isRead: true, isGlobalNotification: true)
        let otherNotification = NotificationModel(id: "4", type: .score, isRead: false)
        interactor.mockedNotifications = [unreadAnnouncement, readAnnouncement, globalAnnouncement, otherNotification]
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Then
        if case .data(let announcements) = testee.state {
            XCTAssertEqual(announcements.count, 1)
            XCTAssertTrue(announcements.contains(where: { $0.id == "1" }))
        } else {
            XCTFail("Expected state to be .data, but was \(testee.state)")
        }
    }

    func testFetchAnnouncements_whenEmpty_returnsEmptyData() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: false)
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)
        interactor.mockedNotifications = []

        // Then
        if case .data(let announcements) = testee.state {
            XCTAssertTrue(announcements.isEmpty)
        } else {
            XCTFail("Expected state to be .data, but was \(testee.state)")
        }
    }

    func testFetchAnnouncementsOnErrorReturnsEmptyData() {
        // Given
        let interactor = NotificationInteractorMock(shouldReturnError: true)
        let testee = AnnouncementsListWidgetViewModel(interactor: interactor, router: router, scheduler: .immediate)

        // Then
        if case .data(let announcements) = testee.state {
            XCTAssertTrue(announcements.isEmpty)
        } else {
            XCTFail("Expected state to be .data, but was \(testee.state)")
        }
    }

    // MARK: - Navigation

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
}

// MARK: - Mock Extensions

private extension NotificationModel {
    init(
        id: String,
        type: NotificationType,
        isRead: Bool = false,
        isGlobalNotification: Bool = false,
        announcementId: String? = nil
    ) {
        self.init(
            id: id,
            title: "Title \(id)",
            date: Date(),
            isRead: isRead,
            courseName: "Course",
            courseID: "1",
            enrollmentID: "1",
            isScoreAnnouncement: false,
            type: type,
            announcementId: announcementId,
            assignmentURL: nil,
            htmlURL: nil
        )
    }
}
