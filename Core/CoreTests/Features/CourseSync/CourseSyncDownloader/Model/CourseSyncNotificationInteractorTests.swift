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

import Combine
@testable import Core
import TestsFoundation
import XCTest

class CourseSyncNotificationInteractorTests: CoreTestCase {

    func testSendsSuccessNotificationWithItemCount() {
        let testee = CourseSyncNotificationInteractor(localNotifications: LocalNotificationsInteractor(notificationCenter: notificationCenter),
                                                      progressInteractor: CourseSyncProgressObserverInteractorMock())

        // WHEN
        XCTAssertFinish(testee.send())

        // THEN
        guard let notification = notificationCenter.requests.last else {
            return XCTFail()
        }

        XCTAssertTrue(notification.content.body.hasPrefix("13"))
    }

    func testDoesntSendsSuccessNotificationWithZeroItemCount() {
        let interactorMock = CourseSyncProgressObserverInteractorMock()
        interactorMock.stateProgresses = []

        let testee = CourseSyncNotificationInteractor(localNotifications: LocalNotificationsInteractor(notificationCenter: notificationCenter),
                                                      progressInteractor: interactorMock)

        // WHEN
        XCTAssertFinish(testee.send())

        // THEN
        guard notificationCenter.requests.last == nil else {
            return XCTFail()
        }
    }

    func testNotSendsSuccessNotificationWhenSyncProgressIsOnScreen() {
        window.rootViewController = CourseSyncProgressAssembly.makeViewController(env: environment)
        let testee = CourseSyncNotificationInteractor(localNotifications: LocalNotificationsInteractor(notificationCenter: notificationCenter),
                                                      progressInteractor: CourseSyncProgressObserverInteractorMock())

        // WHEN
        XCTAssertFinish(testee.send())

        // THEN
        XCTAssertNil(notificationCenter.requests.last)
    }

    func testSendsFailedNotification() {
        let progressObserverMock = CourseSyncProgressObserverInteractorMock()
        progressObserverMock.isSyncFailed = true
        let testee = CourseSyncNotificationInteractor(localNotifications: LocalNotificationsInteractor(notificationCenter: notificationCenter),
                                                      progressInteractor: progressObserverMock)

        // WHEN
        XCTAssertFinish(testee.send())

        // THEN
        guard let notification = notificationCenter.requests.last else {
            return XCTFail()
        }

        XCTAssertEqual(notification.content.title, "Offline Content Sync Failed")
        XCTAssertEqual(notification.content.body, "One or more items failed to sync. Please check your internet connection and retry syncing.")
    }

    func testNotSendsFailedNotificationWhenSyncProgressIsOnScreen() {
        window.rootViewController = CourseSyncProgressAssembly.makeViewController(env: environment)
        let progressObserverMock = CourseSyncProgressObserverInteractorMock()
        progressObserverMock.isSyncFailed = true
        let testee = CourseSyncNotificationInteractor(localNotifications: LocalNotificationsInteractor(notificationCenter: notificationCenter),
                                                      progressInteractor: progressObserverMock)

        // WHEN
        XCTAssertFinish(testee.send())

        // THEN
        XCTAssertNil(notificationCenter.requests.last)
    }
}

private class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {
    var isSyncFailed = false
    var stateProgresses: [CourseSyncStateProgress]?

    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never> {
        let progress = CourseSyncDownloadProgress(bytesToDownload: 0,
                                                  bytesDownloaded: 0,
                                                  isFinished: true,
                                                  error: isSyncFailed ? "error" : nil,
                                                  courseIds: [])
        return Just(progress).eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<[CourseSyncStateProgress], Never> {
        let progresses: [CourseSyncStateProgress]

        if let stateProgresses {
            progresses = stateProgresses
        } else {
            progresses = (0 ..< 13).map { _ in
                CourseSyncStateProgress(id: "", selection: .course("1"), state: .downloaded, entryID: "", tabID: "", fileID: "", progress: nil)
            }
        }
        return Just(progresses).eraseToAnyPublisher()
    }
}
