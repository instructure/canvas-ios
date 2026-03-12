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
import XCTest

class CourseSyncListInteractorLiveTests: CoreTestCase {
    private var testee: CourseSyncListInteractorLive!
    private var entryComposerMock: MockCourseSyncEntryComposerInteractor!

    private var scheduler: AnySchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        environment.userDefaults?.offlineSyncSelections = []
        entryComposerMock = MockCourseSyncEntryComposerInteractor()
        scheduler = .immediate
        testee = CourseSyncListInteractorLive(
            entryComposerInteractor: CourseSyncEntryComposerInteractorLive(),
            scheduler: scheduler
        )
    }

    override func tearDown() {
        super.tearDown()
        entryComposerMock = nil
        scheduler = nil
        testee = nil
    }

    func testCourseIdFilter() {
        let mockAPIRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: [.tabs]
        )
        api.mock(mockAPIRequest, value: [.make()])

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .courseId("1"))
            .sink(
                receiveCompletion: { _ in }) { list in
                    entries = list
            }

        drainMainQueue()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].courseId, "1")
        subscription.cancel()
    }

    func testAllFilter() {
        let mockAPIRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: [.tabs]
        )
        api.mock(mockAPIRequest, value: [.make(id: "1", name: "1"), .make(id: "2", name: "2")])

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .all)
            .sink(
                receiveCompletion: { _ in }) { list in
                    entries = list
            }

        drainMainQueue()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].courseId, "1")
        XCTAssertEqual(entries[1].courseId, "2")
        subscription.cancel()
    }

    func testCourseIdsFilter() {
        environment.userDefaults?.offlineSyncSelections = ["courses/1", "courses/2"]
        CourseSyncSelectorCourse.save(.make(id: "1", name: "1"), in: databaseClient)
        CourseSyncSelectorCourse.save(.make(id: "2", name: "2"), in: databaseClient)
        try? databaseClient.save()

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .courseIds(["1", "2"]))
            .sink(
                receiveCompletion: { _ in }) { list in
                    entries = list
            }

        drainMainQueue()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].courseId, "1")
        XCTAssertEqual(entries[1].courseId, "2")
        XCTAssertEqual(environment.userDefaults?.offlineSyncSelections, ["courses/1", "courses/2"])
        subscription.cancel()
    }

    func testInteractorDeallocationNotCrashesActiveStream() {
        let mockAPIRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: [.tabs]
        )
        api.mock(mockAPIRequest, value: [.make()])
        let streamFinished = expectation(description: "")

        // WHEN
        let subscription = {
            let mockComposer = MockCourseSyncEntryComposerInteractor()
            let testee = CourseSyncListInteractorLive(entryComposerInteractor: mockComposer)
            return testee
                .getCourseSyncEntries(filter: .all)
                .sink(receiveCompletion: { _ in
                    streamFinished.fulfill()
                }, receiveValue: { _ in })
        }()

        // THEN
        // At this point testee is deallocated but the stream subscription is alive
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testPreviousSelectionCleanUp() {
        environment.userDefaults?.offlineSyncSelections = ["courses/1", "courses/2"]
        let mockAPIRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: [.tabs]
        )
        api.mock(mockAPIRequest, value: [.make(id: "1", name: "1")])

        XCTAssertFinish(testee.getCourseSyncEntries(filter: .all))
        XCTAssertEqual(environment.userDefaults?.offlineSyncSelections, ["courses/1"])
    }

    // MARK: - Embedded Content Error

    func testEmbeddedContentErrorCourseIsIncludedWhenDeselected() {
        // GIVEN
        CourseSyncSelectorCourse.save(.make(id: "1", name: "1"), in: databaseClient)
        try? databaseClient.save()
        let progress = CourseSyncDownloadProgress.make(
            isFinished: true,
            error: CourseSyncDownloadProgress.embeddedContentErrorMessage,
            embeddedContentErrorCourseIds: ["1"]
        )

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .courseIds(["1"]), progress: progress)
            .sink(receiveCompletion: { _ in }) { entries = $0 }
        drainMainQueue()

        // THEN
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].courseId, "1")
        XCTAssertEqual(entries[0].state, .downloaded(isEmbeddedMediaComplete: false))
        subscription.cancel()
    }

    func testEmbeddedContentErrorCourseIsExcludedWhenProgressIsNil() {
        // GIVEN
        CourseSyncSelectorCourse.save(.make(id: "1", name: "1"), in: databaseClient)
        try? databaseClient.save()

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .courseIds(["1"]))
            .sink(receiveCompletion: { _ in }) { entries = $0 }
        drainMainQueue()

        // THEN
        XCTAssertTrue(entries.isEmpty)
        subscription.cancel()
    }

    func testEmbeddedContentErrorCourseIsExcludedWhenCourseIdNotInErrorList() {
        // GIVEN
        CourseSyncSelectorCourse.save(.make(id: "1", name: "1"), in: databaseClient)
        try? databaseClient.save()
        let progress = CourseSyncDownloadProgress.make(
            isFinished: true,
            error: CourseSyncDownloadProgress.embeddedContentErrorMessage,
            embeddedContentErrorCourseIds: ["2"]
        )

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .courseIds(["1"]), progress: progress)
            .sink(receiveCompletion: { _ in }) { entries = $0 }
        drainMainQueue()

        // THEN
        XCTAssertTrue(entries.isEmpty)
        subscription.cancel()
    }

    func testEmbeddedContentErrorSelectedEntryTakesPrecedence() {
        // GIVEN — course is fully selected AND has an embedded content error
        environment.userDefaults?.offlineSyncSelections = ["courses/1"]
        CourseSyncSelectorCourse.save(.make(id: "1", name: "1"), in: databaseClient)
        try? databaseClient.save()
        let progress = CourseSyncDownloadProgress.make(
            isFinished: true,
            error: CourseSyncDownloadProgress.embeddedContentErrorMessage,
            embeddedContentErrorCourseIds: ["1"]
        )

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries(filter: .courseIds(["1"]), progress: progress)
            .sink(receiveCompletion: { _ in }) { entries = $0 }
        drainMainQueue()

        // THEN — entry appears once via the limitedResults path, not the error path
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].courseId, "1")
        XCTAssertNotEqual(entries[0].state, .downloaded(isEmbeddedMediaComplete: false))
        subscription.cancel()
    }

    func testEmbeddedContentErrorEntryHasDeselectedTabsAndFilesRemoved() {
        // GIVEN
        let selectedTab = CourseSyncEntry.Tab(id: "tab-pages", name: "Pages", type: .pages, isCollapsed: false, selectionState: .selected)
        let deselectedTab = CourseSyncEntry.Tab(id: "tab-assignments", name: "Assignments", type: .assignments, isCollapsed: false, selectionState: .deselected)
        let file = CourseSyncEntry.File.make(id: "file-1", displayName: "doc.pdf")
        let mockEntry = CourseSyncEntry.make(
            id: "courses/1",
            tabs: [selectedTab, deselectedTab],
            files: [file]
        )
        let mockComposer = MockCourseSyncEntryComposerInteractor(mockEntry: mockEntry)
        let localTestee = CourseSyncListInteractorLive(
            entryComposerInteractor: mockComposer,
            scheduler: .immediate
        )
        CourseSyncSelectorCourse.save(.make(id: "1", name: "1"), in: databaseClient)
        try? databaseClient.save()
        let progress = CourseSyncDownloadProgress.make(
            isFinished: true,
            error: CourseSyncDownloadProgress.embeddedContentErrorMessage,
            embeddedContentErrorCourseIds: ["1"]
        )

        // WHEN
        var entries = [CourseSyncEntry]()
        let subscription = localTestee.getCourseSyncEntries(filter: .courseIds(["1"]), progress: progress)
            .sink(receiveCompletion: { _ in }) { entries = $0 }
        drainMainQueue()

        // THEN
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].state, .downloaded(isEmbeddedMediaComplete: false))
        XCTAssertEqual(entries[0].tabs.count, 1)
        XCTAssertEqual(entries[0].tabs[0].id, "tab-pages")
        XCTAssertTrue(entries[0].files.isEmpty)
        subscription.cancel()
    }
}

class MockCourseSyncEntryComposerInteractor: CourseSyncEntryComposerInteractor {
    private let mockEntry: CourseSyncEntry

    init(mockEntry: CourseSyncEntry = .make()) {
        self.mockEntry = mockEntry
    }

    func composeEntry(from _: CourseSyncSelectorCourse,
                      useCache _: Bool)
        -> AnyPublisher<CourseSyncEntry, Error> {
        Just(mockEntry)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
