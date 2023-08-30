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

class CourseSyncProgressInteractorLiveTests: CoreTestCase {
    private var listInteractor: CourseSyncListInteractor!
    private var entryComposerInteractorMock: CourseSyncEntryComposerInteractorMock!
    private var progressObserverInteractorMock: CourseSyncProgressObserverInteractorMock!
    private var sesssionDefaults: SessionDefaults!

    override func setUp() {
        super.setUp()
        entryComposerInteractorMock = CourseSyncEntryComposerInteractorMock()
        progressObserverInteractorMock = CourseSyncProgressObserverInteractorMock()
        sesssionDefaults = SessionDefaults(sessionID: "uniqueID")
        listInteractor = CourseSyncListInteractorLive(
            entryComposerInteractor: entryComposerInteractorMock,
            sessionDefaults: sesssionDefaults,
            scheduler: .immediate
        )
    }

    override func tearDown() {
        listInteractor = nil
        entryComposerInteractorMock = nil
        progressObserverInteractorMock = nil
        sesssionDefaults = nil
        super.tearDown()
    }

    func testCourseSelection() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults
        )

        createAndSaveCourseSyncSelectorCourse()
        sesssionDefaults.offlineSyncSelections = ["courses/course-id-1"]

        // WHEN
        var entries = [CourseSyncEntry]()
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { newList in
                    entries = newList
                    expectation.fulfill()
                }
            )
        drainMainQueue()
        mockEntryComposeCourse()

        // THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].selectionState, .selected)
        XCTAssertEqual(entries[0].tabs[0].selectionState, .selected)
        XCTAssertEqual(entries[0].tabs[1].selectionState, .selected)
        XCTAssertEqual(entries[0].files[0].selectionState, .selected)

        subscription.cancel()
    }

    func testPartialSelection() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults
        )

        createAndSaveCourseSyncSelectorCourse()
        sesssionDefaults.offlineSyncSelections = ["courses/course-id-1/tabs/assignments"]

        // WHEN
        var entries = [CourseSyncEntry]()
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { newList in
                    entries = newList
                    expectation.fulfill()
                }
            )
        drainMainQueue()
        mockEntryComposeCourse()

        // THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].selectionState, .partiallySelected)
        XCTAssertEqual(entries[0].tabs.count, 1)
        XCTAssertEqual(entries[0].tabs[0].id, "courses/course-id-1/tabs/assignments")
        XCTAssertEqual(entries[0].tabs[0].selectionState, .selected)
        XCTAssertEqual(entries[0].files.count, 0)

        subscription.cancel()
    }

    func testNoPreviousSelection() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults
        )

        createAndSaveCourseSyncSelectorCourse()
        sesssionDefaults.offlineSyncSelections = [""]

        // WHEN
        var entries = [CourseSyncEntry]()
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.observeEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { newList in
                    entries = newList
                    expectation.fulfill()
                }
            )
        drainMainQueue()
        mockEntryComposeCourse()

        // THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 0)

        subscription.cancel()
    }

    func testDownloadedEntryProgress() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults,
            scheduler: .immediate
        )

        createAndSaveCourseSyncSelectorCourse()
        sesssionDefaults.offlineSyncSelections = ["courses/course-id-1"]

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = testee.observeEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { newList in
                    entries = newList
                }
            )
        drainMainQueue()
        mockEntryComposeCourse()

        // THEN
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))
        XCTAssertEqual(entries[0].files[0].state, .loading(nil))

        progressObserverInteractorMock.entryProgressSubject.send(.data([
            CourseSyncStateProgress.save(
                id: "courses/course-id-1",
                selection: .file("courses/course-id-1", "courses/course-id-1/files/file-1"),
                state: .loading(0.4),
                in: databaseClient
            ),
        ]))
        XCTAssertEqual(entries[0].files[0].state, .loading(0.4))

        progressObserverInteractorMock.entryProgressSubject.send(.data([
            CourseSyncStateProgress.save(
                id: "courses/course-id-1",
                selection: .file("courses/course-id-1", "courses/course-id-1/files/file-1"),
                state: .downloaded,
                in: databaseClient
            ),
        ]))
        XCTAssertEqual(entries[0].files[0].state, .downloaded)

        progressObserverInteractorMock.entryProgressSubject.send(.data([
            CourseSyncStateProgress.save(
                id: "courses/course-id-1",
                selection: .tab("courses/course-id-1", "courses/course-id-1/tabs/files"),
                state: .downloaded,
                in: databaseClient
            ),
        ]))
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)

        progressObserverInteractorMock.entryProgressSubject.send(.data([
            CourseSyncStateProgress.save(
                id: "courses/course-id-1",
                selection: .course("courses/course-id-1"),
                state: .downloaded,
                in: databaseClient
            ),
        ]))
        XCTAssertEqual(entries[0].state, .downloaded)
        subscription.cancel()
    }

    func testFailedEntryProgress() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults,
            scheduler: .immediate
        )

        createAndSaveCourseSyncSelectorCourse()
        sesssionDefaults.offlineSyncSelections = ["courses/course-id-1"]

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = testee.observeEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { newList in
                    entries = newList
                }
            )
        drainMainQueue()
        mockEntryComposeCourse()

        // THEN
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))

        progressObserverInteractorMock.entryProgressSubject.send(.data([
            CourseSyncStateProgress.save(
                id: "courses/course-id-1",
                selection: .tab("courses/course-id-1", "courses/course-id-1/tabs/assignments"),
                state: .error,
                in: databaseClient
            ),
        ]))
        XCTAssertEqual(entries[0].tabs[1].state, .error)
        subscription.cancel()
    }

    func testRetry() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults,
            scheduler: .immediate
        )

        createAndSaveCourseSyncSelectorCourse()
        sesssionDefaults.offlineSyncSelections = ["courses/course-id-1"]

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription1 = testee.observeEntries()
            .sink()

        let subscription2 = NotificationCenter.default.publisher(for: .OfflineSyncTriggered)
            .compactMap { $0.object as? [CourseSyncEntry] }
            .sink(receiveValue: { newList in
                entries = newList
            })

        drainMainQueue()
        entryComposerInteractorMock.courseSyncEntrySubject.send(
            CourseSyncEntry(
                name: "course-name-1",
                id: "courses/course-id-1",
                tabs: [
                    .init(id: "courses/course-id-1/tabs/files", name: "tab-files", type: .files, state: .error),
                    .init(id: "courses/course-id-1/tabs/assignments", name: "tab-assignments", type: .assignments, state: .downloaded),
                ],
                files: [
                    .init(
                        id: "courses/course-id-1/files/file-1",
                        displayName: "file-displayname-1",
                        fileName: "file-name-1",
                        url: URL(string: "https://canvas.instructure.com/files/1/download")!,
                        mimeClass: "image",
                        updatedAt: nil,
                        state: .error,
                        bytesToDownload: 1000
                    ),
                    .init(
                        id: "courses/course-id-1/files/file-2",
                        displayName: "file-displayname-2",
                        fileName: "file-name-2",
                        url: URL(string: "https://canvas.instructure.com/files/2/download")!,
                        mimeClass: "image",
                        updatedAt: nil,
                        state: .downloaded,
                        bytesToDownload: 1000
                    ),
                ],
                state: .loading(nil)
            )
        )

        entryComposerInteractorMock.courseSyncEntrySubject.send(completion: .finished)

        testee.retrySync()

        // THEN
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs.count, 2)
        XCTAssertEqual(entries[0].tabs[0].id, "courses/course-id-1/tabs/files")
        XCTAssertEqual(entries[0].tabs[0].state, .error)
        XCTAssertEqual(entries[0].files.count, 2)
        XCTAssertEqual(entries[0].files[0].id, "courses/course-id-1/files/file-1")

        subscription1.cancel()
        subscription2.cancel()
    }

    func testCancel() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            courseSyncListInteractor: listInteractor,
            progressObserverInteractor: progressObserverInteractorMock,
            sessionDefaults: sesssionDefaults,
            scheduler: .immediate
        )
        var notificationFired = false
        let subscription = NotificationCenter.default
            .publisher(for: .OfflineSyncCancelled)
            .sink(receiveValue: { _ in notificationFired = true })

        // WHEN
        testee.cancelSync()

        // THEN
        XCTAssertTrue(notificationFired)
    }

    private func createAndSaveCourseSyncSelectorCourse() {
        CourseSyncSelectorCourse.save(
            .make(
                id: "course-id-1",
                name: "course-name-1",
                tabs: [
                    .make(id: "files", label: "tab-files-1")
                ]
            ),
            in: databaseClient
        )

        try? databaseClient.save()
    }

    private func mockEntryComposeCourse() {
        entryComposerInteractorMock.courseSyncEntrySubject.send(
            CourseSyncEntry(
                name: "course-name-1",
                id: "courses/course-id-1",
                tabs: [
                    .init(id: "courses/course-id-1/tabs/files", name: "tab-files", type: .files),
                    .init(id: "courses/course-id-1/tabs/assignments", name: "tab-assignments", type: .assignments),
                ],
                files: [
                    .init(
                        id: "courses/course-id-1/files/file-1",
                        displayName: "file-displayname-1",
                        fileName: "file-name-1",
                        url: URL(string: "https://canvas.instructure.com/files/1/download")!,
                        mimeClass: "image",
                        updatedAt: nil,
                        bytesToDownload: 1000
                    ),
                ]
            )
        )
        entryComposerInteractorMock.courseSyncEntrySubject.send(completion: .finished)
    }
}

private class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {
    let entryProgressSubject = PassthroughSubject<ReactiveStore<Core.GetCourseSyncStateProgressUseCase>.State, Never>()

    func observeDownloadProgress() -> AnyPublisher<Core.ReactiveStore<Core.GetCourseSyncDownloadProgressUseCase>.State, Never> {
        Just(ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State.data([]))
            .eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<Core.ReactiveStore<Core.GetCourseSyncStateProgressUseCase>.State, Never> {
        entryProgressSubject.eraseToAnyPublisher()
    }
}
