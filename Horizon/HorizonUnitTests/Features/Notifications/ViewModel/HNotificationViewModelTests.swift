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

@testable import Core
@testable import Horizon
import XCTest

final class HNotificationViewModelTests: HorizonTestCase {
    func testRefresh() async {
        // Given
        let testee = HNotificationViewModel(interactor: NotificationInteractorMock(), router: router)
        // When
        _ = await testee.refresh()
        // Then
        XCTAssertEqual(testee.notifications.count, 10)
        XCTAssertTrue(testee.isSeeMoreButtonVisible)
        XCTAssertEqual(testee.notifications[0].type, .score)
        XCTAssertEqual(testee.notifications[1].type, .scoreChanged)
        XCTAssertEqual(testee.notifications[2].type, .dueDate)
    }

    func testRefreshShowError() async {
        // Given
        let testee = HNotificationViewModel(
            interactor: NotificationInteractorMock(shouldReturnError: true),
            router: router
        )
        // When
        _ = await testee.refresh()
        // Then
        XCTAssertEqual(testee.notifications.count, 0)
        XCTAssertTrue(testee.isErrorVisiable)

    }

    func testRefreshSeeMore() async {
        // Given
        let testee = HNotificationViewModel(interactor: NotificationInteractorMock(), router: router)
        // When
        _ = await testee.refresh()
        testee.seeMore()
        // Then
        XCTAssertEqual(testee.notifications.count, 11)
        XCTAssertFalse(testee.isSeeMoreButtonVisible)
    }

    func testNavigeteToDetailsRouteToModuleItemSequnce() {
        // Given
        let testee = HNotificationViewModel(interactor: NotificationInteractorMock(), router: router)
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        let notification = NotificationModel(
            id: "1",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .score,
            announcementId: "announcementId-1",
            assignmentURL: URL(string: "https://horizon.cd.instructure.com/courses/477/assignments/43973"),
            htmlURL: nil
        )
        // When
        testee.navigateToDetails(notification: notification, viewController: viewController)
        // Then
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: "https://horizon.cd.instructure.com/courses/477/assignments/43973"))
        XCTAssertEqual(router.calls.last?.1, sourceView)
        XCTAssertEqual(router.calls.last?.2, .push)
        wait(for: [router.routeExpectation], timeout: 1)
    }

    func testNavigeteToDetailsRouteToModuleItemSequnceWithHtmlURL() {
        // Given
        let testee = HNotificationViewModel(interactor: NotificationInteractorMock(), router: router)
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        let notification = NotificationModel(
            id: "1",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .dueDate,
            announcementId: "announcementId-1",
            assignmentURL: nil,
            htmlURL: URL(string: "https://horizon.cd.instructure.com/courses/477/assignments/43973")
        )
        // When
        testee.navigateToDetails(notification: notification, viewController: viewController)
        // Then
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: "https://horizon.cd.instructure.com/courses/477/assignments/43973"))
        XCTAssertEqual(router.calls.last?.1, sourceView)
        XCTAssertEqual(router.calls.last?.2, .push)
        wait(for: [router.routeExpectation], timeout: 1)
    }

    func testNavigeteToDetailsRouteToCourseDetails() {
        // Given
        let testee = HNotificationViewModel(interactor: NotificationInteractorMock(), router: router)
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        let notification = NotificationModel(
            id: "1",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .score,
            announcementId: "announcementId-1",
            assignmentURL: nil,
            htmlURL: nil
        )
        // When
        testee.navigateToDetails(notification: notification, viewController: viewController)
        // Then
        let courseDetailsView = router.lastViewController as? CoreHostingController<Horizon.CourseDetailsView>
        XCTAssertNotNil(courseDetailsView)
        wait(for: [router.showExpectation], timeout: 1)
    }

    func testNavigeteToDetailsRouteToInbox() {
        // Given
        let testee = HNotificationViewModel(interactor: NotificationInteractorMock(), router: router)
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        let notification = NotificationModel(
            id: "1",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .announcement,
            announcementId: "announcementId-1",
            assignmentURL: nil,
            htmlURL: nil
        )
        // When
        testee.navigateToDetails(notification: notification, viewController: viewController)
        // Then
        let messageDetailsView = router.lastViewController as? CoreHostingController<Horizon.HMessageDetailsView>
        XCTAssertNotNil(messageDetailsView)
        wait(for: [router.showExpectation], timeout: 1)
    }

    func testAccessibilityPropertiesWithValues() {
        // Given
        let model = NotificationModel(
            id: "1",
            title: "My Title",
            date: Date.fromISO8601("2025-09-24T06:27:18Z"),
            isRead: false,
            courseName: "AI Introduction",
            courseID: "1",
            enrollmentID: "enrollment",
            isScoreAnnouncement: false,
            type: .announcement
        )

        // When
        let courseAccessibility = model.accessibilityCourseName
        let dateAccessibility = model.accessibilityDate
        let titleAccessibility = model.accessibilityTitle

        // Then
        XCTAssertEqual(courseAccessibility, "Course AI Introduction")
        XCTAssertEqual(dateAccessibility, "Date Sep 24, 2025")
        XCTAssertEqual(titleAccessibility, "Title My Title")
    }
}
