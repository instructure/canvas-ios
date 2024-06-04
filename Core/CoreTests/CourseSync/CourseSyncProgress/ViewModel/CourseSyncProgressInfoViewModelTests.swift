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
import CombineExt
@testable import Core
import XCTest

class CourseSyncProgressInfoViewModelTests: CoreTestCase {
    private var courseSyncProgressInteractorMock: MockCourseSyncProgressInteractor!

    override func setUp() {
        courseSyncProgressInteractorMock = MockCourseSyncProgressInteractor()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        courseSyncProgressInteractorMock = nil
    }

    func testProgressDetails() {
        // GIVEN
        let testee = CourseSyncProgressInfoViewModel(
            interactor: courseSyncProgressInteractorMock,
            scheduler: .immediate
        )
        let fileProgress = CourseSyncDownloadProgress.make(
            bytesToDownload: 1000,
            bytesDownloaded: 500,
            isFinished: false,
            error: nil
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(fileProgress)

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$state,
            .downloadInProgress(message: "Downloading 500 bytes of 1 KB", progress: 0.5)
        )
    }

    func testErrorIsShownWhenFinished() {
        // GIVEN
        let testee = CourseSyncProgressInfoViewModel(
            interactor: courseSyncProgressInteractorMock,
            scheduler: .immediate
        )
        let fileProgress = CourseSyncDownloadProgress.make(
            bytesToDownload: 1000,
            bytesDownloaded: 0,
            isFinished: true,
            error: "Download failed."
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(fileProgress)

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$state,
            .finishedWithError(title: "Offline Content Sync Failed",
                               subtitle: "One or more items failed to sync. Please check your internet connection and retry syncing.")
        )
    }

    func testSuccessfullyFinishedState() {
        // GIVEN
        let testee = CourseSyncProgressInfoViewModel(
            interactor: courseSyncProgressInteractorMock,
            scheduler: .immediate
        )
        let fileProgress = CourseSyncDownloadProgress.make(
            bytesToDownload: 1000,
            bytesDownloaded: 1000,
            isFinished: true,
            error: nil
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(fileProgress)

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$state,
            .finishedSuccessfully(message: "Success! Downloaded 1 KB of 1 KB", progress: 1)
        )
    }

    func testErrorIsNotShownUntilFinished() {
        // GIVEN
        let testee = CourseSyncProgressInfoViewModel(
            interactor: courseSyncProgressInteractorMock,
            scheduler: .immediate
        )
        let fileProgress = CourseSyncDownloadProgress.make(
            bytesToDownload: 1000,
            bytesDownloaded: 0,
            isFinished: false,
            error: "Download failed."
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(fileProgress)

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$state,
            .downloadStarting(message: "Downloading Zero KB of 1 KB")
        )
    }
}
