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
import Foundation
import TestsFoundation
import XCTest

class CourseSyncProgressWriterInteractorLiveTests: CoreTestCase {
    var entries: [CourseSyncEntry]!

    override func setUp() {
        super.setUp()
        entries = [
            CourseSyncEntry(
                name: "course-1",
                id: "course-1",
                tabs: [],
                files: [
                    .make(id: "file-1", displayName: "file-1", bytesToDownload: 1000),
                    .make(id: "file-2", displayName: "file-2", bytesToDownload: 1000),
                ]
            ),
        ]
    }

    override func tearDown() {
        entries = nil
        super.tearDown()
    }

    func testDownloadedFileProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .downloaded
        entries[0].files[1].state = .downloaded
        testee.saveDownloadProgress(entries: entries)

        let progressList: [CourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        XCTAssertEqual(progressList[0].bytesToDownload, 2000)
        XCTAssertEqual(progressList[0].bytesDownloaded, 2000)
        XCTAssertEqual(progressList[0].progress, 1)
    }

    func testPartiallyDownloadedFileProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .loading(0.5)
        entries[0].files[1].state = .loading(0.5)
        testee.saveDownloadProgress(entries: entries)

        let progressList: [CourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        XCTAssertEqual(progressList[0].bytesToDownload, 2000)
        XCTAssertEqual(progressList[0].bytesDownloaded, 1000)
        XCTAssertEqual(progressList[0].progress, 0.5)
    }

    func testFailedDownloadFileProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .error
        entries[0].files[1].state = .loading(0.5)
        testee.saveDownloadProgress(entries: entries)

        let progressList: [CourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        XCTAssertEqual(progressList[0].bytesToDownload, 2000)
        XCTAssertEqual(progressList[0].bytesDownloaded, 500)
        XCTAssertEqual(progressList[0].progress, 0.25)
    }

    func testCourseSelectionEntryProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)
        testee.saveStateProgress(id: "1", selection: .course("0"), state: .downloaded)
        testee.saveStateProgress(id: "2", selection: .course("0"), state: .error)
        testee.saveStateProgress(id: "3", selection: .course("0"), state: .loading(nil))

        let progressList: [CourseSyncStateProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 3)

        XCTAssertEqual(progressList[0].id, "1")
        XCTAssertEqual(progressList[0].selection, .course("0"))
        XCTAssertEqual(progressList[0].state, .downloaded)

        XCTAssertEqual(progressList[1].id, "2")
        XCTAssertEqual(progressList[1].selection, .course("0"))
        XCTAssertEqual(progressList[1].state, .error)

        XCTAssertEqual(progressList[2].id, "3")
        XCTAssertEqual(progressList[2].selection, .course("0"))
        XCTAssertEqual(progressList[2].state, .loading(nil))
    }

    func testTabSelectionEntryProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)
        testee.saveStateProgress(id: "1", selection: .tab("0", "0"), state: .downloaded)
        testee.saveStateProgress(id: "2", selection: .tab("0", "0"), state: .error)
        testee.saveStateProgress(id: "3", selection: .tab("0", "0"), state: .loading(nil))

        let progressList: [CourseSyncStateProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 3)

        XCTAssertEqual(progressList[0].id, "1")
        XCTAssertEqual(progressList[0].selection, .tab("0", "0"))
        XCTAssertEqual(progressList[0].state, .downloaded)

        XCTAssertEqual(progressList[1].id, "2")
        XCTAssertEqual(progressList[1].selection, .tab("0", "0"))
        XCTAssertEqual(progressList[1].state, .error)

        XCTAssertEqual(progressList[2].id, "3")
        XCTAssertEqual(progressList[2].selection, .tab("0", "0"))
        XCTAssertEqual(progressList[2].state, .loading(nil))
    }

    func testFileSelectionEntryProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)
        testee.saveStateProgress(id: "1", selection: .file("0", "0"), state: .downloaded)
        testee.saveStateProgress(id: "2", selection: .file("0", "0"), state: .error)
        testee.saveStateProgress(id: "3", selection: .file("0", "0"), state: .loading(nil))

        let progressList: [CourseSyncStateProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 3)

        XCTAssertEqual(progressList[0].id, "1")
        XCTAssertEqual(progressList[0].selection, .file("0", "0"))
        XCTAssertEqual(progressList[0].state, .downloaded)

        XCTAssertEqual(progressList[1].id, "2")
        XCTAssertEqual(progressList[1].selection, .file("0", "0"))
        XCTAssertEqual(progressList[1].state, .error)

        XCTAssertEqual(progressList[2].id, "3")
        XCTAssertEqual(progressList[2].selection, .file("0", "0"))
        XCTAssertEqual(progressList[2].state, .loading(nil))
    }
}
