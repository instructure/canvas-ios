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
    private var entryComposerInteractorMock: CourseSyncEntryComposerInteractorMock!
    private var progressObserverInteractorMock: CourseSyncProgressObserverInteractorMock!
    private var sesssionDefaults: SessionDefaults!

    override func setUp() {
        super.setUp()
        entryComposerInteractorMock = CourseSyncEntryComposerInteractorMock()
        progressObserverInteractorMock = CourseSyncProgressObserverInteractorMock()
        sesssionDefaults = SessionDefaults(sessionID: "uniqueID")
    }

    override func tearDown() {
        entryComposerInteractorMock = nil
        progressObserverInteractorMock = nil
        sesssionDefaults = nil
        super.tearDown()
    }

    func testCourseSelection() {
        // GIVEN
        let testee = CourseSyncProgressInteractorLive(
            entryComposerInteractor: entryComposerInteractorMock,
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
            entryComposerInteractor: entryComposerInteractorMock,
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
            entryComposerInteractor: entryComposerInteractorMock,
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
                        bytesToDownload: 1000
                    ),
                ]
            )
        )
        entryComposerInteractorMock.courseSyncEntrySubject.send(completion: .finished)
    }
}

class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {
    let entryProgressSubject = PassthroughSubject<ReactiveStore<Core.GetCourseSyncEntryProgressUseCase>.State, Never>()

    func observeFileProgress() -> AnyPublisher<Core.ReactiveStore<Core.GetCourseSyncFileProgressUseCase>.State, Never> {
        Just(ReactiveStore<GetCourseSyncFileProgressUseCase>.State.data([]))
            .eraseToAnyPublisher()
    }

    func observeEntryProgress() -> AnyPublisher<Core.ReactiveStore<Core.GetCourseSyncEntryProgressUseCase>.State, Never> {
        entryProgressSubject.eraseToAnyPublisher()
    }
}
