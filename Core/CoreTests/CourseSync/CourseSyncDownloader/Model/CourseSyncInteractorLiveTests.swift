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
                    .init(id: "tab-discussions", name: "Discussions", type: .discussions),
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

    func testStartsDiscussionsDownload() {
        let expectation = expectation(description: "Discussions download started")
        let mockDiscussionsInteractor = CourseSyncDiscussionsInteractorMock(expectation: expectation)
        let testee = CourseSyncInteractorLive(
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
                mockDiscussionsInteractor,
            ],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            scheduler: .immediate
        )
        entries[0].tabs[6].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    func testInitialLoadingState() {
        let testee = CourseSyncInteractorLive(
            contentInteractors: [pagesInteractor, assignmentsInteractor],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            scheduler: .immediate
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        let courseProgress: CourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CourseSyncStateProgress.id), equals: "entry-1")
        ).first!
        XCTAssertEqual(courseProgress.state, .loading(nil))

        let assignmentsProgress: CourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CourseSyncStateProgress.id), equals: "tab-assignments")
        ).first!
        XCTAssertEqual(assignmentsProgress.state, .loading(nil))

        let pagesProgress: CourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CourseSyncStateProgress.id), equals: "tab-pages")
        ).first!
        XCTAssertEqual(pagesProgress.state, .loading(nil))

        let file1Progress: CourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CourseSyncStateProgress.id), equals: "file-1")
        ).first!
        XCTAssertEqual(file1Progress.state, .loading(nil))

        let file2Progress: CourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CourseSyncStateProgress.id), equals: "file-1")
        ).first!
        XCTAssertEqual(file2Progress.state, .loading(nil))

        subscription.cancel()
    }

    func testCancellation() {
        // GIVEN
        let testee = CourseSyncInteractorLive(
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            scheduler: .immediate
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected

        testee.downloadContent(for: entries).sink()
        assignmentsInteractor.publisher.send(())
        pagesInteractor.publisher.send(())

        // WHEN
        NotificationCenter.default.post(name: .OfflineSyncCancelled, object: nil)

        // THEN
        let fileProgressList: [CourseSyncDownloadProgress] = databaseClient.fetch()
        let entryProgressList: [CourseSyncStateProgress] = databaseClient.fetch()
        XCTAssertEqual(fileProgressList.count, 0)
        XCTAssertEqual(entryProgressList.count, 0)
        XCTAssertEqual(testee.downloadSubscription, nil)
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

private class CourseSyncDiscussionsInteractorMock: CourseSyncDiscussionsInteractor {
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

    func getFile(url _: URL, fileID _: String, fileName _: String, mimeClass _: String, updatedAt _: Date?) -> AnyPublisher<Float, Error> {
        publisher.eraseToAnyPublisher()
    }
}
