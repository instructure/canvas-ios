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
import Foundation
import TestsFoundation
import XCTest
import CombineSchedulers

class CourseSyncInteractorLiveTests: CoreTestCase {
    private var assignmentsInteractor: CourseSyncAssignmentsInteractorMock!
    private var pagesInteractor: CourseSyncPagesInteractorMock!
    private var filesInteractor: CourseSyncFilesInteractorMock!
    private var progressWriterInteractor: CourseSyncProgressWriterInteractor!
    private var progressObserverInteractor: CourseSyncProgressObserverInteractor!
    private var entries: [CourseSyncEntry]!

    override func setUp() {
        assignmentsInteractor = CourseSyncAssignmentsInteractorMock()
        pagesInteractor = CourseSyncPagesInteractorMock()
        filesInteractor = CourseSyncFilesInteractorMock()
        progressWriterInteractor = CourseSyncProgressWriterInteractorLive(context: databaseClient)
        progressObserverInteractor = CourseSyncProgressObserverInteractorLive(context: databaseClient)

        entries = [
            CourseSyncEntry(
                name: "entry-1",
                id: "entry-1",
                tabs: [
                    .init(id: "tab-assignments", name: "Assignments", type: .assignments),
                    .init(id: "tab-pages", name: "Pages", type: .pages),
                    .init(id: "tab-files", name: "Files", type: .files),
                ],
                files: [
                    .make(id: "file-1", displayName: "1", url: URL(string: "1.jpg")!, bytesToDownload: 1000),
                    .make(id: "file-2", displayName: "2", url: URL(string: "2.jpg")!, bytesToDownload: 1000),
                ]
            ),
        ]
    }

    override func tearDown() {
        assignmentsInteractor = nil
        pagesInteractor = nil
        filesInteractor = nil
        progressWriterInteractor = nil
        progressObserverInteractor = nil
        entries = []
        super.tearDown()
    }

    func testDownloadState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor,
            scheduler: .immediate
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        assignmentsInteractor.publisher.send(())
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        pagesInteractor.publisher.send(())
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(1)
        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)

        subscription.cancel()
    }

    func testDownloadStateProgressSaving() {
        let syncInteractor = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor,
            progressWriterInteractor: progressWriterInteractor
        )
        entries[0].selectionState = .partiallySelected
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        var progressList = [CourseSyncEntryProgress]()
        let expectation1 = expectation(description: "ObserveEntryProgress publisher sends value")
        expectation1.expectedFulfillmentCount = 11

        let subscription1 = progressObserverInteractor.observeEntryProgress()
            .sink(
                receiveValue: { val in
                    if case let .data(list) = val {
                        progressList = list.sorted()
                        expectation1.fulfill()
                    }
                }
            )

        let expectation2 = expectation(description: "DownloadContent publisher sends value")
        expectation2.expectedFulfillmentCount = 11
        let subscription2 = syncInteractor.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation2.fulfill()
                }
            )

        drainMainQueue()
        XCTAssertEqual(progressList[0].selection, .course(0))
        XCTAssertEqual(progressList[0].state, .loading(nil))
        XCTAssertEqual(progressList[1].selection, .tab(0, 0))
        XCTAssertEqual(progressList[1].state, .loading(nil))
        XCTAssertEqual(progressList[2].selection, .tab(0, 1))
        XCTAssertEqual(progressList[2].state, .loading(nil))
        XCTAssertEqual(progressList[3].selection, .tab(0, 2))
        XCTAssertEqual(progressList[3].state, .loading(nil))
        XCTAssertEqual(progressList[4].selection, .file(0, 0))
        XCTAssertEqual(progressList[4].state, .loading(nil))
        XCTAssertEqual(progressList[5].selection, .file(0, 1))
        XCTAssertEqual(progressList[5].state, .loading(nil))

        assignmentsInteractor.publisher.send(())
        // Course
        XCTAssertEqual(progressList[0].state, .loading(nil))
        // Assignments Tab
        XCTAssertEqual(progressList[1].state, .downloaded)
        // Pages Tab
        XCTAssertEqual(progressList[2].state, .loading(nil))
        // Files Tab
        XCTAssertEqual(progressList[3].state, .loading(nil))
        // Files #1
        XCTAssertEqual(progressList[4].state, .loading(nil))
        // Files #2
        XCTAssertEqual(progressList[5].state, .loading(nil))

        pagesInteractor.publisher.send(())
        // Course
        XCTAssertEqual(progressList[0].state, .loading(nil))
        // Assignments Tab
        XCTAssertEqual(progressList[1].state, .downloaded)
        // Pages Tab
        XCTAssertEqual(progressList[2].state, .downloaded)
        // Files Tab
        XCTAssertEqual(progressList[3].state, .loading(nil))
        // Files #1
        XCTAssertEqual(progressList[4].state, .loading(nil))
        // Files #2
        XCTAssertEqual(progressList[5].state, .loading(nil))

        filesInteractor.publisher.send(1)
        filesInteractor.publisher.send(completion: .finished)
        // Course
        XCTAssertEqual(progressList[0].state, .downloaded)
        // Assignments Tab
        XCTAssertEqual(progressList[1].state, .downloaded)
        // Pages Tab
        XCTAssertEqual(progressList[2].state, .downloaded)
        // Files Tab
        XCTAssertEqual(progressList[3].state, .downloaded)
        // Files #1
        XCTAssertEqual(progressList[4].state, .downloaded)
        // Files #2
        XCTAssertEqual(progressList[5].state, .downloaded)

        waitForExpectations(timeout: 2)
        subscription1.cancel()
        subscription2.cancel()
    }

    func testFilesLoadingState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor
        )
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 9
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(0.1)
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[0].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[1].state, .loading(0.1))

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)
        XCTAssertEqual(entries[0].files[0].state, .downloaded)
        XCTAssertEqual(entries[0].files[1].state, .downloaded)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testFilesDownloadedBytes() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor
        )
        entries[0].selectionState = .partiallySelected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let expectation = expectation(description: "DownloadContent publisher sends value")
        expectation.expectedFulfillmentCount = 9
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        drainMainQueue()
        XCTAssertEqual(entries.totalSelectedSize, 2000)
        XCTAssertEqual(entries.totalDownloadedSize, 0)
        XCTAssertEqual(entries[0].files[0].bytesToDownload, 1000)
        XCTAssertEqual(entries[0].files[1].bytesToDownload, 1000)

        filesInteractor.publisher.send(0.1)
        XCTAssertEqual(entries[0].files[0].bytesDownloaded, 100)
        XCTAssertEqual(entries.totalDownloadedSize, 200)

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].files[0].bytesDownloaded, 1000)
        XCTAssertEqual(entries[0].files[1].bytesDownloaded, 1000)
        XCTAssertEqual(entries.totalDownloadedSize, 2000)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testFilesPartialSelection() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor
        )
        entries[0].tabs[2].selectionState = .partiallySelected
        entries[0].files[0].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 6
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(0.1)
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[0].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[1].state, .loading(nil))

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)
        XCTAssertEqual(entries[0].files[0].state, .downloaded)
        XCTAssertEqual(entries[0].files[1].state, .loading(nil))

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testAssignmentErrorState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor
        )
        entries[0].tabs[0].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 3
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .loading(nil))

        assignmentsInteractor.publisher.send(completion: .failure(NSError.instructureError("Assignment error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[0].state, .error)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testPagesErrorState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor
        )
        entries[0].tabs[1].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 3
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))

        pagesInteractor.publisher.send(completion: .failure(NSError.instructureError("Pages error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[1].state, .error)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testFilesErrorState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor
        )
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 5
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(completion: .failure(NSError.instructureError("Pages error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[2].state, .error)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }
}

private class CourseSyncPagesInteractorMock: CourseSyncPagesInteractor {
    let publisher = PassthroughSubject<Void, Error>()

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        publisher.eraseToAnyPublisher()
    }
}

private class CourseSyncAssignmentsInteractorMock: CourseSyncAssignmentsInteractor {
    let publisher = PassthroughSubject<Void, Error>()

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        publisher.eraseToAnyPublisher()
    }
}

private class CourseSyncFilesInteractorMock: CourseSyncFilesInteractor {
    let publisher = PassthroughSubject<Float, Error>()

    func getFile(url _: URL, fileID _: String, fileName _: String, mimeClass _: String) -> AnyPublisher<Float, Error> {
        publisher.eraseToAnyPublisher()
    }
}
