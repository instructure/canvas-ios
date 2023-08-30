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

class CourseSyncProgressViewModelTests: CoreTestCase {
    var testee: CourseSyncProgressViewModel!
    var mockProgressInteractor: MockCourseSyncProgressInteractor!
    var mockSyncInteractor: CourseSyncInteractorMock!

    override func setUp() {
        super.setUp()
        mockProgressInteractor = MockCourseSyncProgressInteractor()
        mockSyncInteractor = CourseSyncInteractorMock()
        router = TestRouter()
        testee = CourseSyncProgressViewModel(interactor: mockProgressInteractor, router: router)
    }

    func testInitialState() {
        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.cells, [])
    }

    func testCancelTap() {
        testee.cancelButtonDidTap.accept(())
        XCTAssertEqual(testee.isShowingCancelDialog, true)
    }

    func testCancelConfirmTap() {
        let controller = UIViewController()
        let weakController = WeakViewController(controller)
        testee.cancelButtonDidTap.accept(())
        testee.viewOnAppear.accept(weakController)
        testee.confirmAlert.notifyCompletion(isConfirmed: true)
        XCTAssertEqual(router.dismissed, controller)
    }

    func testDismissTap() {
        let controller = UIViewController()
        let weakController = WeakViewController(controller)
        testee.dismissButtonDidTap.accept(weakController)
        XCTAssertEqual(router.dismissed, controller)
    }

    func testUpdateStateFails() {
        mockProgressInteractor.courseSyncEntriesSubject.send(completion: .failure(NSError.instructureError("Failed")))
        waitUntil(shouldFail: true) {
            testee.state == .error
        }
    }

    func testUpdateStateSucceeds() {
        let mockItem = CourseSyncEntry(name: "",
                                       id: "test",
                                       tabs: [],
                                       files: [])
        mockProgressInteractor.courseSyncEntriesSubject.send([mockItem])
        mockProgressInteractor.courseSyncFileProgressSubject.send(.data([]))
        waitUntil(shouldFail: true) {
            testee.state == .data
        }
        XCTAssertEqual(testee.cells.count, 1)

        guard case .item(let item) = testee.cells.first else {
            return XCTFail()
        }

        XCTAssertEqual(item.id, "test")
    }

    func testUpdateStateDataWithErrorIsShownWhenFinished() {
        let mockItem = CourseSyncEntry(name: "",
                                       id: "test",
                                       tabs: [],
                                       files: [])
        mockProgressInteractor.courseSyncEntriesSubject.send([mockItem])

        let mockFileProgress: CourseSyncDownloadProgress = databaseClient.insert()
        mockFileProgress.bytesDownloaded = 1
        mockFileProgress.bytesToDownload = 2
        mockFileProgress.error = "File download failed."
        mockFileProgress.isFinished = true
        mockProgressInteractor.courseSyncFileProgressSubject.send(.data([mockFileProgress]))

        waitUntil(shouldFail: true) {
            testee.state == .dataWithError
        }
        XCTAssertEqual(testee.cells.count, 1)

        guard case .item(let item) = testee.cells.first else {
            return XCTFail()
        }

        XCTAssertEqual(item.id, "test")
    }

    func testUpdateStateDataWithErrorIsNotShownUntilFinished() {
        let mockItem = CourseSyncEntry(name: "",
                                       id: "test",
                                       tabs: [],
                                       files: [])
        mockProgressInteractor.courseSyncEntriesSubject.send([mockItem])

        let mockFileProgress: CourseSyncDownloadProgress = databaseClient.insert()
        mockFileProgress.bytesDownloaded = 1
        mockFileProgress.bytesToDownload = 2
        mockFileProgress.error = "File download failed."
        mockFileProgress.isFinished = false
        mockProgressInteractor.courseSyncFileProgressSubject.send(.data([mockFileProgress]))

        waitUntil(shouldFail: true) {
            testee.state == .data
        }
        XCTAssertEqual(testee.cells.count, 1)

        guard case .item(let item) = testee.cells.first else {
            return XCTFail()
        }

        XCTAssertEqual(item.id, "test")
    }
}
