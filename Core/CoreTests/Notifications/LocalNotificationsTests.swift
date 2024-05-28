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

class LocalNotificationsTests: CoreTestCase {

    func testOfflineSyncCompletedSuccessfullyNotificationSingular() {
        XCTAssertFinish(notificationManager.sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: 1))

        guard let firstNotification = notificationCenter.requests.first else {
            return XCTFail()
        }

        XCTAssertEqual(firstNotification.content.title, "Offline Content Sync Success")
        XCTAssertEqual(firstNotification.content.body, "1 course has been synced.")
    }

    func testOfflineSyncCompletedSuccessfullyNotificationPlural() {
        XCTAssertFinish(notificationManager.sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: 2))

        guard let firstNotification = notificationCenter.requests.first else {
            return XCTFail()
        }

        XCTAssertEqual(firstNotification.content.title, "Offline Content Sync Success")
        XCTAssertEqual(firstNotification.content.body, "2 courses have been synced.")
    }

    func testOfflineSyncFailed() {
        XCTAssertFinish(notificationManager.sendOfflineSyncFailedNotification())

        guard let firstNotification = notificationCenter.requests.first else {
            return XCTFail()
        }

        XCTAssertEqual(firstNotification.content.title, "Offline Content Sync Failed")
        XCTAssertEqual(firstNotification.content.body, "One or more items failed to sync. Please check your internet connection and retry syncing.")
    }
}
