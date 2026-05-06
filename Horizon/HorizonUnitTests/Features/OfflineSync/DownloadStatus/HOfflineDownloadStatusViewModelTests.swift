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

import CombineSchedulers
@testable import Core
@testable import Horizon
import XCTest

final class HOfflineDownloadStatusViewModelTests: HorizonTestCase {

    private static let testData = (
        courseID: "course 1",
        progress: 0.42,
        downloadedSize: "42 MB",
        totalSize: "100 MB"
    )
    private lazy var testData = Self.testData

    private var syncInteractor: HCourseSyncInteractorMock!
    private var testee: HOfflineDownloadStatusViewModel!

    override func setUp() {
        super.setUp()
        syncInteractor = HCourseSyncInteractorMock()
        testee = HOfflineDownloadStatusViewModel(
            syncInteractor: syncInteractor,
            scheduler: .immediate
        )
    }

    override func tearDown() {
        testee = nil
        syncInteractor = nil
        super.tearDown()
    }

    // MARK: - Progress publisher

    func test_syncProgress_whenProgressPublished_shouldUpdateOutputs() {
        let progress = HOfflineSyncProgress(
            progress: testData.progress,
            downloadedSize: testData.downloadedSize,
            totalSize: testData.totalSize,
            isComplete: false
        )

        syncInteractor.progressSubject.send(progress)

        XCTAssertEqual(testee.syncProgress, testData.progress)
        XCTAssertEqual(testee.syncDownloadedSize, testData.downloadedSize)
        XCTAssertEqual(testee.syncTotalSize, testData.totalSize)
    }

    // MARK: - Download items publisher

    func test_courses_whenDownloadItemsPublished_shouldUpdateCourses() {
        let course = OfflineCourseItem(
            id: testData.courseID,
            enrollmentID: "12",
            name: "course name",
            size: nil,
            isExpanded: false,
            isSelected: true,
            subItems: []
        )

        syncInteractor.downloadItemsSubject.send([course])

        XCTAssertEqual(testee.courses.count, 1)
        XCTAssertEqual(testee.courses.first?.id, testData.courseID)
    }

    // MARK: - Error publisher

    func test_isError_whenErrorPublished_shouldBeTrue() {
        syncInteractor.errorSubject.send(())

        XCTAssertEqual(testee.isError, true)
    }

    // MARK: - cancelSync

    func test_cancelSync_shouldForwardToInteractor() {
        testee.cancelSync()

        XCTAssertEqual(syncInteractor.cancelSyncCallCount, 1)
    }

    // MARK: - retrySync

    func test_retrySync_shouldResetIsError() {
        syncInteractor.errorSubject.send(())
        XCTAssertEqual(testee.isError, true)

        testee.retrySync()

        XCTAssertEqual(testee.isError, false)
    }

    func test_retrySync_shouldCallDownloadContentWithCurrentCourses() {
        let course = OfflineCourseItem(
            id: testData.courseID,
            enrollmentID: "33",
            name: "course name",
            size: nil,
            isExpanded: false,
            isSelected: true,
            subItems: []
        )
        syncInteractor.downloadItemsSubject.send([course])

        testee.retrySync()

        XCTAssertEqual(syncInteractor.downloadContentCallCount, 1)
        XCTAssertEqual(syncInteractor.lastDownloadedCourses.first?.id, testData.courseID)
    }
}
