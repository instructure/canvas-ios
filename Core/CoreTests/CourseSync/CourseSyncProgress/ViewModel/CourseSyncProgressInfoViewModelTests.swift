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
        let fileProgress = CourseSyncDownloadProgress.save(
            bytesToDownload: 1000,
            bytesDownloaded: 500,
            isFinished: false,
            error: nil,
            in: databaseClient
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(.data([fileProgress]))

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$progress,
            "Downloading 500 bytes of 1 KB"
        )
        XCTAssertSingleOutputEquals(
            testee.$progressPercentage,
            0.5
        )
    }

    func testErrorIsShownWhenFinished() {
        // GIVEN
        let testee = CourseSyncProgressInfoViewModel(
            interactor: courseSyncProgressInteractorMock,
            scheduler: .immediate
        )
        let fileProgress = CourseSyncDownloadProgress.save(
            bytesToDownload: 1000,
            bytesDownloaded: 0,
            isFinished: true,
            error: "Download failed.",
            in: databaseClient
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(.data([fileProgress]))

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$syncFailure,
            true
        )
        XCTAssertSingleOutputEquals(
            testee.$syncFailureTitle,
            "Offline Content Sync Failed"
        )
        XCTAssertSingleOutputEquals(
            testee.$syncFailureSubtitle,
            "One or more files failed to sync. Check your internet connection and retry to submit."
        )
    }

    func testErrorIsNotShownUntilFinished() {
        // GIVEN
        let testee = CourseSyncProgressInfoViewModel(
            interactor: courseSyncProgressInteractorMock,
            scheduler: .immediate
        )
        let fileProgress = CourseSyncDownloadProgress.save(
            bytesToDownload: 1000,
            bytesDownloaded: 0,
            isFinished: false,
            error: "Download failed.",
            in: databaseClient
        )

        // WHEN
        courseSyncProgressInteractorMock.courseSyncFileProgressSubject.send(.data([fileProgress]))

        // THEN
        XCTAssertSingleOutputEquals(
            testee.$syncFailure,
            false
        )
    }
}
