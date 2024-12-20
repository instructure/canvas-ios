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

class CDCourseSyncDownloadProgressTests: CoreTestCase {
    func testProperties() {
        let progress: CDCourseSyncDownloadProgress = databaseClient.insert()
        progress.bytesToDownload = 1000
        progress.bytesDownloaded = 100
        progress.isFinished = false
        progress.error = nil
        progress.courseIds = ["abc, xyz"]

        let testee: CDCourseSyncDownloadProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.bytesToDownload, 1000)
        XCTAssertEqual(testee.bytesDownloaded, 100)
        XCTAssertEqual(testee.isFinished, false)
        XCTAssertEqual(testee.error, nil)
        XCTAssertEqual(testee.courseIds, ["abc, xyz"])
    }

    func testSave() {
        _ = CDCourseSyncDownloadProgress.save(
            bytesToDownload: 1000,
            bytesDownloaded: 500,
            isFinished: false,
            error: nil,
            courseIds: ["abc"],
            in: databaseClient
        )

        let testee: CDCourseSyncDownloadProgress = databaseClient.fetch().first!
        XCTAssertEqual(testee.bytesToDownload, 1000)
        XCTAssertEqual(testee.bytesDownloaded, 500)
        XCTAssertEqual(testee.isFinished, false)
        XCTAssertEqual(testee.error, nil)
        XCTAssertEqual(testee.courseIds, ["abc"])
    }
}
