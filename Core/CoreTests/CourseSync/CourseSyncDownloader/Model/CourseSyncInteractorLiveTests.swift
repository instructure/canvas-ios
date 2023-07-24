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
import CombineSchedulers
@testable import Core
import Foundation
import TestsFoundation
import XCTest

class CourseSyncInteractorLiveTests: CoreTestCase {
    private var assignmentsInteractor: CourseSyncAssignmentsInteractorMock!
    private var pagesInteractor: CourseSyncPagesInteractorMock!
    private var filesInteractor: CourseSyncFilesInteractorMock!
    private var progressWriterInteractor: CourseSyncProgressWriterInteractor!
    private var progressObserverInteractor: CourseSyncProgressObserverInteractor!
    private var entries: [CourseSyncEntry]!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        assignmentsInteractor = CourseSyncAssignmentsInteractorMock()
        pagesInteractor = CourseSyncPagesInteractorMock()
        filesInteractor = CourseSyncFilesInteractorMock()
        progressWriterInteractor = CourseSyncProgressWriterInteractorLive(container: database)
        progressObserverInteractor = CourseSyncProgressObserverInteractorLive(container: database)
        testScheduler = DispatchQueue.test

        entries = [
            CourseSyncEntry(
                name: "entry-1",
                id: "entry-1",
                tabs: [
                    .init(id: "tab-assignments", name: "Assignments", type: .assignments),
                    .init(id: "tab-pages", name: "Pages", type: .pages),
                    .init(id: "tab-files", name: "Files", type: .files),
                    .init(id: "tab-syllabus", name: "Syllabus", type: .syllabus),
                    .init(id: "tab-conferences", name: "Conferences", type: .conferences),
                    .init(id: "tab-quizzes", name: "Quizzes", type: .quizzes),
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
        testScheduler = nil
        super.tearDown()
    }

    func testDownloadState() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [pagesInteractor, assignmentsInteractor],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
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

    /*
    func testDownloadStateProgressSaving() {
        let syncInteractor = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor,
            filesInteractor: filesInteractor,
            progressWriterInteractor: progressWriterInteractor,
            scheduler: .immediate
        )
        entries[0].selectionState = .partiallySelected
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        var progressList = [CourseSyncEntryProgress]()
        let subscription1 = progressObserverInteractor.observeEntryProgress()
            .dropFirst()
            .sink(
                receiveValue: { val in
                    if case let .data(list) = val {
                        progressList = list.sorted()
                    }
                }
            )

        let subscription2 = syncInteractor.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        drainMainQueue()
        XCTAssertEqual(progressList[0].selection, .course("entry-1"))
        XCTAssertEqual(progressList[0].state, .loading(nil))
        XCTAssertEqual(progressList[1].selection, .tab("entry-1", "tab-assignments"))
        XCTAssertEqual(progressList[1].state, .loading(nil))
        XCTAssertEqual(progressList[2].selection, .tab("entry-1", "tab-files"))
        XCTAssertEqual(progressList[2].state, .loading(nil))
        XCTAssertEqual(progressList[3].selection, .tab("entry-1", "tab-pages"))
        XCTAssertEqual(progressList[3].state, .loading(nil))
        XCTAssertEqual(progressList[4].selection, .file("entry-1", "file-1"))
        XCTAssertEqual(progressList[4].state, .loading(nil))
        XCTAssertEqual(progressList[5].selection, .file("entry-1", "file-2"))
        XCTAssertEqual(progressList[5].state, .loading(nil))

        assignmentsInteractor.publisher.send(())
        drainMainQueue()
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
        drainMainQueue()
        // Course
        XCTAssertEqual(progressList[0].state, .loading(nil))
        // Assignments Tab
        XCTAssertEqual(progressList[1].state, .downloaded)
        // Files Tab
        XCTAssertEqual(progressList[2].state, .loading(nil))
        // Pages Tab
        XCTAssertEqual(progressList[3].state, .downloaded)
        // Files #1
        XCTAssertEqual(progressList[4].state, .loading(nil))
        // Files #2
        XCTAssertEqual(progressList[5].state, .loading(nil))

        filesInteractor.publisher.send(1)
        drainMainQueue()
        filesInteractor.publisher.send(completion: .finished)
        drainMainQueue()
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

        subscription1.cancel()
        subscription2.cancel()
    }
     */

    func testFilesLoadingState() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
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

        subscription.cancel()
    }

    func testFilesDownloadedBytes() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].selectionState = .partiallySelected
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

        subscription.cancel()
    }

    func testFilesPartialSelection() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[2].selectionState = .partiallySelected
        entries[0].files[0].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(0.1)
        testScheduler.run()
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[0].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[1].state, .loading(nil))

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)
        XCTAssertEqual(entries[0].files[0].state, .downloaded)
        XCTAssertEqual(entries[0].files[1].state, .loading(nil))

        subscription.cancel()
    }

    func testAssignmentErrorState() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [assignmentsInteractor],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .loading(nil))

        assignmentsInteractor.publisher.send(completion: .failure(NSError.instructureError("Assignment error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[0].state, .error)
        XCTAssertEqual(entries[0].files[0].state, .idle)
        XCTAssertEqual(entries[0].files[1].state, .idle)

        subscription.cancel()
    }

    func testPagesErrorState() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [pagesInteractor],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))

        pagesInteractor.publisher.send(completion: .failure(NSError.instructureError("Pages error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[1].state, .error)
        XCTAssertEqual(entries[0].files[0].state, .idle)
        XCTAssertEqual(entries[0].files[1].state, .idle)

        subscription.cancel()
    }

    func testFilesErrorState() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
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
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(completion: .failure(NSError.instructureError("Files error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[2].state, .error)

        subscription.cancel()
    }

    func testStartsSyllabusDownload() {
        let syllbusDownloadStarted = expectation(description: "Syllabus download started")
        let mockSyllabusInteractor = CourseSyncSyllabusInteractorMock(expectation: syllbusDownloadStarted)
        let testee = CourseSyncInteractorLive(
            contentInteractors: [mockSyllabusInteractor],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[3].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [syllbusDownloadStarted], timeout: 1)
        subscription.cancel()
    }

    func testStartsConferencesDownload() {
        let conferencesDownloadStarted = expectation(description: "Conferences download started")
        let mockConferencesInteractor = CourseSyncConferencesInteractorMock(expectation: conferencesDownloadStarted)
        let testee = CourseSyncInteractorLive(
            contentInteractors: [mockConferencesInteractor],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[4].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [conferencesDownloadStarted], timeout: 1)
        subscription.cancel()
    }

    func testStartsQuizzesDownload() {
        let expectation = expectation(description: "Quizzes download started")
        let mockQuizzesInteractor = CourseSyncQuizzesInteractorMock(expectation: expectation)
        let testee = CourseSyncInteractorLive(
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
                mockQuizzesInteractor,
            ],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[5].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }
}

// MARK: - Mocks

private class CourseSyncSyllabusInteractorMock: CourseSyncSyllabusInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class CourseSyncConferencesInteractorMock: CourseSyncConferencesInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class CourseSyncQuizzesInteractorMock: CourseSyncQuizzesInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
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
