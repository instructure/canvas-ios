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
                hasFrontPage: false,
                tabs: [],
                files: [
                    .make(id: "file-1", displayName: "file-1", bytesToDownload: 1000),
                    .make(id: "file-2", displayName: "file-2", bytesToDownload: 1000)
                ]
            )
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

        let progressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        let progress = CourseSyncDownloadProgress(from: progressList[0])
        XCTAssertEqual(progress.bytesToDownload, 2000)
        XCTAssertEqual(progress.bytesDownloaded, 2000)
        XCTAssertEqual(progress.progress, 1)
    }

    func testPartiallyDownloadedFileProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .loading(0.5)
        entries[0].files[1].state = .loading(0.5)
        testee.saveDownloadProgress(entries: entries)

        let progressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        let progress = CourseSyncDownloadProgress(from: progressList[0])
        XCTAssertEqual(progress.bytesToDownload, 2000)
        XCTAssertEqual(progress.bytesDownloaded, 1000)
        XCTAssertEqual(progress.progress, 0.5)
    }

    func testFailedDownloadFileProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .error
        entries[0].files[1].state = .loading(0.5)
        testee.saveDownloadProgress(entries: entries)

        let progressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        let progress = CourseSyncDownloadProgress(from: progressList[0])
        XCTAssertEqual(progress.bytesToDownload, 2000)
        XCTAssertEqual(progress.bytesDownloaded, 500)
        XCTAssertEqual(progress.progress, 0.25)
    }

    func testSavedCourseIds() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .loading(0.5)
        entries[0].files[1].state = .loading(0.5)
        testee.saveDownloadProgress(entries: entries)

        let progressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(progressList.count, 1)
        let progress = CourseSyncDownloadProgress(from: progressList[0])
        XCTAssertEqual(progress.courseIds, ["course-1"])

        entries.append(CourseSyncEntry(
            name: "course-2",
            id: "course-2",
            hasFrontPage: false,
            tabs: [],
            files: []
        ))

        testee.saveDownloadProgress(entries: entries)
        let updatedProgressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch(scope: .all)
        let updatedProgress = CourseSyncDownloadProgress(from: updatedProgressList[0])
        XCTAssertEqual(updatedProgress.courseIds, ["course-1", "course-2"])
    }

    func testCourseSelectionEntryProgress() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)
        testee.saveStateProgress(id: "1", selection: .course("0"), state: .downloaded)
        testee.saveStateProgress(id: "2", selection: .course("0"), state: .error)
        testee.saveStateProgress(id: "3", selection: .course("0"), state: .loading(nil))

        let progressList: [CDCourseSyncStateProgress] = databaseClient.fetch(scope: .all)
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

        let progressList: [CDCourseSyncStateProgress] = databaseClient.fetch(scope: .all)
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

        let progressList: [CDCourseSyncStateProgress] = databaseClient.fetch(scope: .all)
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

    func testMarkInProgressDownloadsAsFailed() {
        let testee = CourseSyncProgressWriterInteractorLive(container: database)
        testee.saveStateProgress(id: "1", selection: .file("0", "0"), state: .downloaded)
        testee.saveStateProgress(id: "2", selection: .file("0", "0"), state: .error)
        testee.saveStateProgress(id: "3", selection: .file("0", "0"), state: .loading(nil))

        let progressList: [CDCourseSyncStateProgress] = databaseClient.fetch(scope: .all(orderBy: #keyPath(CDCourseSyncStateProgress.id)))
        XCTAssertEqual(progressList[0].state, .downloaded)
        XCTAssertEqual(progressList[1].state, .error)
        XCTAssertEqual(progressList[2].state, .loading(nil))

        // WHEN
        testee.markInProgressDownloadsAsFailed()

        // THEN
        XCTAssertEqual(progressList[0].state, .downloaded)
        XCTAssertEqual(progressList[1].state, .error)
        XCTAssertEqual(progressList[2].state, .error)
    }
}
