//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest

class LocalNotificationsInteractorTests: CoreTestCase {
    var testee: LocalNotificationsInteractor!

    override func setUp() {
        super.setUp()
        testee = LocalNotificationsInteractor(notificationCenter: notificationCenter)
    }

    func testNotificationRequest() {
        let request = UNNotificationRequest(
            identifier: "one",
            title: "Title",
            body: "Body",
            route: "/courses"
        )
        XCTAssertEqual(request.content.title, "Title")
        XCTAssertEqual(request.content.body, "Body")
        XCTAssertEqual(request.identifier, "one")
        XCTAssert(request.trigger is UNTimeIntervalNotificationTrigger)
        XCTAssertEqual((request.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 1)
        XCTAssertEqual((request.trigger as? UNTimeIntervalNotificationTrigger)?.repeats, false)
        XCTAssertEqual(request.content.userInfo[UNNotificationContent.RouteURLKey] as? String, "/courses")
    }

    func testOfflineSyncCompletedSuccessfullyNotificationSingular() {
        XCTAssertFinish(testee.sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: 1))

        guard let firstNotification = notificationCenter.requests.first else {
            return XCTFail()
        }

        XCTAssertEqual(firstNotification.content.title, "Offline Content Sync Success")
        XCTAssertEqual(firstNotification.content.body, "1 course has been synced.")
    }

    func testOfflineSyncCompletedSuccessfullyNotificationPlural() {
        XCTAssertFinish(testee.sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: 2))

        guard let firstNotification = notificationCenter.requests.first else {
            return XCTFail()
        }

        XCTAssertEqual(firstNotification.content.title, "Offline Content Sync Success")
        XCTAssertEqual(firstNotification.content.body, "2 courses have been synced.")
    }

    func testOfflineSyncFailed() {
        XCTAssertFinish(testee.sendOfflineSyncFailedNotification())

        guard let firstNotification = notificationCenter.requests.first else {
            return XCTFail()
        }

        XCTAssertEqual(firstNotification.content.title, "Offline Content Sync Failed")
        XCTAssertEqual(firstNotification.content.body, "One or more items failed to sync. Please check your internet connection and retry syncing.")
    }
}
