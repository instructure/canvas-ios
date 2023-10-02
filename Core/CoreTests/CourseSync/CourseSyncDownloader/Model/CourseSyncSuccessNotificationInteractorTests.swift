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
import Combine
import XCTest
import TestsFoundation

class CourseSyncSuccessNotificationInteractorTests: CoreTestCase {

    func testSendsNotificationWithItemCount() {
        let testee = CourseSyncSuccessNotificationInteractor(notificationManager: notificationManager,
                                                             progressInteractor: CourseSyncProgressObserverInteractorMock())

        // WHEN
        XCTAssertFinish(testee.send())

        // THEN
        guard let notification = notificationCenter.requests.last else {
            return XCTFail()
        }

        XCTAssertTrue(notification.content.body.hasPrefix("13"))
    }

    func testNotSendsNotificationWhenSyncProgressIsOnScreen() {
        window.rootViewController = CourseSyncProgressAssembly.makeViewController(env: environment)
        let testee = CourseSyncSuccessNotificationInteractor(notificationManager: notificationManager,
                                                             progressInteractor: CourseSyncProgressObserverInteractorMock())

        // WHEN
        XCTAssertFinish(testee.send(window: window))

        // THEN
        XCTAssertNil(notificationCenter.requests.last)
    }
}

private class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {

    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never> {
        Just(CourseSyncDownloadProgress(bytesToDownload: 0, bytesDownloaded: 0, isFinished: false, error: nil)).eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<[CourseSyncStateProgress], Never> {
        let progresses = (0..<13).map { _ in
            CourseSyncStateProgress(id: "", selection: .course("1"), state: .downloaded, entryID: "", tabID: "", fileID: "", progress: nil)
        }
        return Just(progresses).eraseToAnyPublisher()
    }
}
