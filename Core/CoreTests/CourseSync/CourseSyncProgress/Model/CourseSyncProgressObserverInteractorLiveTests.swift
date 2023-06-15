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

class CourseSyncProgressObserverInteractorLiveTests: CoreTestCase {
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

    func testDownloadedFileProgressObserver() {
        let testee = CourseSyncProgressObserverInteractorLive(context: databaseClient)
        let helper = CourseSyncProgressWriterInteractorLive(context: databaseClient)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .downloaded
        entries[0].files[1].state = .downloaded
        helper.saveFileProgress(entries: entries)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeFileProgress()
            .sink { state in
                if case let .data(list) = state, let progress = list.first {
                    XCTAssertEqual(progress.bytesToDownload, 2000)
                    XCTAssertEqual(progress.bytesDownloaded, 2000)
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testPartiallyDownloadedFileProgressObserver() {
        let testee = CourseSyncProgressObserverInteractorLive(context: databaseClient)
        let helper = CourseSyncProgressWriterInteractorLive(context: databaseClient)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .loading(0.5)
        entries[0].files[1].state = .loading(0.5)
        helper.saveFileProgress(entries: entries)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeFileProgress()
            .sink { state in
                if case let .data(list) = state, let progress = list.first {
                    XCTAssertEqual(progress.bytesToDownload, 2000)
                    XCTAssertEqual(progress.bytesDownloaded, 1000)
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testFailedDownloadFileProgressObserver() {
        let testee = CourseSyncProgressObserverInteractorLive(context: databaseClient)
        let helper = CourseSyncProgressWriterInteractorLive(context: databaseClient)

        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected
        entries[0].files[0].state = .error
        entries[0].files[1].state = .loading(0.5)
        helper.saveFileProgress(entries: entries)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeFileProgress()
            .sink { state in
                if case let .data(list) = state, let progress = list.first {
                    XCTAssertEqual(progress.bytesToDownload, 2000)
                    XCTAssertEqual(progress.bytesDownloaded, 500)
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testCourseSelectionEntryProgressObserver() {
        let testee = CourseSyncProgressObserverInteractorLive(context: databaseClient)
        let helper = CourseSyncProgressWriterInteractorLive(context: databaseClient)

        helper.saveEntryProgress(id: "1", selection: .course(0), state: .downloaded)
        helper.saveEntryProgress(id: "2", selection: .course(0), state: .error)
        helper.saveEntryProgress(id: "3", selection: .course(0), state: .loading(nil))

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeEntryProgress()
            .sink { state in
                if case let .data(list) = state {
                    XCTAssertEqual(list[0].id, "1")
                    XCTAssertEqual(list[0].selection, .course(0))
                    XCTAssertEqual(list[0].state, .downloaded)

                    XCTAssertEqual(list[1].id, "2")
                    XCTAssertEqual(list[1].selection, .course(0))
                    XCTAssertEqual(list[1].state, .error)

                    XCTAssertEqual(list[2].id, "3")
                    XCTAssertEqual(list[2].selection, .course(0))
                    XCTAssertEqual(list[2].state, .loading(nil))
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testTabSelectionEntryProgressObserver() {
        let testee = CourseSyncProgressObserverInteractorLive(context: databaseClient)
        let helper = CourseSyncProgressWriterInteractorLive(context: databaseClient)

        helper.saveEntryProgress(id: "1", selection: .tab(0, 0), state: .downloaded)
        helper.saveEntryProgress(id: "2", selection: .tab(0, 0), state: .error)
        helper.saveEntryProgress(id: "3", selection: .tab(0, 0), state: .loading(nil))

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeEntryProgress()
            .sink { state in
                if case let .data(list) = state {
                    XCTAssertEqual(list[0].id, "1")
                    XCTAssertEqual(list[0].selection, .tab(0, 0))
                    XCTAssertEqual(list[0].state, .downloaded)

                    XCTAssertEqual(list[1].id, "2")
                    XCTAssertEqual(list[1].selection, .tab(0, 0))
                    XCTAssertEqual(list[1].state, .error)

                    XCTAssertEqual(list[2].id, "3")
                    XCTAssertEqual(list[2].selection, .tab(0, 0))
                    XCTAssertEqual(list[2].state, .loading(nil))
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testFileSelectionEntryProgressObserver() {
        let testee = CourseSyncProgressObserverInteractorLive(context: databaseClient)
        let helper = CourseSyncProgressWriterInteractorLive(context: databaseClient)

        helper.saveEntryProgress(id: "1", selection: .file(0, 0), state: .downloaded)
        helper.saveEntryProgress(id: "2", selection: .file(0, 0), state: .error)
        helper.saveEntryProgress(id: "3", selection: .file(0, 0), state: .loading(nil))

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeEntryProgress()
            .sink { state in
                if case let .data(list) = state {
                    XCTAssertEqual(list[0].id, "1")
                    XCTAssertEqual(list[0].selection, .file(0, 0))
                    XCTAssertEqual(list[0].state, .downloaded)

                    XCTAssertEqual(list[1].id, "2")
                    XCTAssertEqual(list[1].selection, .file(0, 0))
                    XCTAssertEqual(list[1].state, .error)

                    XCTAssertEqual(list[2].id, "3")
                    XCTAssertEqual(list[2].selection, .file(0, 0))
                    XCTAssertEqual(list[2].state, .loading(nil))
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }
}
