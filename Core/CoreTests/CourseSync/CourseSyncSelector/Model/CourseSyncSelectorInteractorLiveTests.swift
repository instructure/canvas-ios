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
import Combine
import Foundation
import TestsFoundation
import XCTest

class CourseSyncSelectorInteractorLiveTests: CoreTestCase {
    private var defaults = SessionDefaults.fallback

    override func setUp() {
        super.setUp()
        defaults.reset()
    }

    override func tearDown() {
        defaults.reset()
        super.tearDown()
    }

    func testCourseList() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")

        mockCourseList()

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        subscription.cancel()
    }

    func testCourseListWithCourseFilter() {
        let testee = CourseSyncSelectorInteractorLive(courseID: "2", sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")

        mockCourseList(courseList: [
            .make(id: "1"),
            .make(id: "2"),
        ])

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.id, "courses/2")
        subscription.cancel()
    }

    func testTabList() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")

        mockCourseList(
            courseList: [
                .make(
                    id: "1",
                    tabs: [
                        .make(id: "assignments", html_url: URL(string: "/assignments")!, label: "Assignments"),
                        .make(id: "files", html_url: URL(string: "/files")!, label: "Files"),
                        .make(id: "pages", html_url: URL(string: "/pages")!, label: "Pages"),
                        .make(id: "quizzes", html_url: URL(string: "/quizzes")!, label: "Quizzes"),
                    ]
                ),
            ]
        )

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].tabs.count, 4)
        subscription.cancel()
    }

    func testFileList() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")

        let rootFolder = APIFolder.make(context_type: "Course", context_id: 1, files_count: 1, id: 0)
        let rootFolderFile = APIFile.make(id: 0, folder_id: 0, display_name: "root-file-1")

        let folder1 = APIFolder.make(id: 1, parent_folder_id: 0)
        let folder1File = APIFile.make(id: 1, folder_id: 1, display_name: "folder-1-file")
        let folder2File = APIFile.make(id: 2, folder_id: 1, display_name: "folder-1-file-locked", locked_for_user: true)
        let folder3File = APIFile.make(id: 2, folder_id: 1, display_name: "folder-1-file-hidden", hidden_for_user: true)

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [folder1], files: [rootFolderFile])
        mockFolderItems(for: "1", folders: [], files: [folder1File, folder2File, folder3File])
        mockCourseList(
            courseList: [.make(id: "1", tabs: [.make(id: "files", label: "Files")])]
        )
        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].files.count, 2)
        XCTAssertEqual(entries[0].files[0].displayName, "root-file-1")
        XCTAssertEqual(entries[0].files[1].displayName, "folder-1-file")
        subscription.cancel()
    }

    func testFileListWhenFilesPageIsUnavailable() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")

        let rootFolder = APIFolder.make(context_type: "Course", context_id: 1, files_count: 1, id: 0)
        let rootFolderFile = APIFile.make(id: 0, folder_id: 0, display_name: "root-file-1")

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [], files: [rootFolderFile])
        mockCourseList()

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].tabs.count, 0)
        XCTAssertEqual(entries[0].files.count, 0)
        subscription.cancel()
    }

    func testDefaultSelection() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")

        mockCourseList(
            courseList: [.make(id: "1", tabs: [.make(id: "files", label: "Files")])]
        )
        let rootFolder = APIFolder.make(context_type: "Course", context_id: 1, files_count: 1, id: 0)
        let rootFolderFile = APIFile.make(id: 0, folder_id: 0, display_name: "root-file-1")

        let folder1 = APIFolder.make(id: 1, parent_folder_id: 0)
        let folder1File = APIFile.make(id: 1, folder_id: 1, display_name: "folder-1-file")

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [folder1], files: [rootFolderFile])
        mockFolderItems(for: "1", folders: [], files: [folder1File])

        var entries = [CourseSyncEntry]()
        let subscription = testee.getCourseSyncEntries()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        XCTAssertFalse(entries[0].selectionState == .selected)
        XCTAssertTrue(entries[0].isCollapsed)
        XCTAssertEqual(entries[0].tabs.count, 1)
        XCTAssertEqual(entries[0].files.count, 2)
        XCTAssertEqual(entries[0].selectedTabsCount, 0)
        XCTAssertEqual(entries[0].selectedFilesCount, 0)
        XCTAssertTrue(entries[0].isCollapsed)
        subscription.cancel()
    }

    func testSelectedEntries() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 2

        mockCourseList(
            courseList: [
                .make(id: "1", name: "course 1", tabs: [.make(id: "files", label: "Files")]),
                .make(id: "2", name: "course 2", tabs: []),
            ]
        )

        let rootFolder = APIFolder.make(context_type: "Course", context_id: 1, files_count: 1, id: 0)
        let rootFolderFile = APIFile.make(id: 0, folder_id: 0, display_name: "root-file-1")

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [], files: [rootFolderFile])

        var entries = [CourseSyncEntry]()
        let subscription1 = testee.getCourseSyncEntries()
            .first()
            .handleEvents(receiveOutput: { _ in
                testee.setSelected(selection: .course("courses/1"), selectionState: .selected)
                testee.setSelected(selection: .file("1", "root-file-1"), selectionState: .selected)
                expectation.fulfill()
            })
            .flatMap { _ in testee.getSelectedCourseEntries() }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    entries = $0
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].selectionState, .selected)
        XCTAssertEqual(entries[0].selectedTabsCount, 1)
        XCTAssertEqual(entries[0].selectedFilesCount, 1)
        subscription1.cancel()
    }

    func testCourseNameWithoutCourseFilter() {
        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        var subscriptions = Set<AnyCancellable>()

        mockCourseList(
            courseList: [
                .make(id: "1", name: "course 1"),
                .make(id: "2", name: "course 2"),
            ]
        )

        let expectation = expectation(description: "Publisher sends value")
        testee.getCourseName()
            .sink { courseName in
                XCTAssertEqual(courseName, "All Courses")
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        testee.getCourseSyncEntries()
            .sink()
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.1)
        subscriptions.removeAll()
    }

    func testCourseNameWithCourseFilter() {
        let testee = CourseSyncSelectorInteractorLive(courseID: "2", sessionDefaults: defaults)
        var subscriptions = Set<AnyCancellable>()

        mockCourseList(
            courseList: [
                .make(id: "1", name: "course 1"),
                .make(id: "2", name: "course 2"),
            ]
        )

        let expectation = expectation(description: "Publisher sends value")
        testee.getCourseName()
            .sink { courseName in
                XCTAssertEqual(courseName, "course 2")
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        testee.getCourseSyncEntries()
            .sink()
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.1)
        subscriptions.removeAll()
    }

    // MARK: - Selection Persistency

    func testAppliesPreviousSelection() {
        // MARK: - GIVEN
        var session = SessionDefaults(sessionID: "oldSession")
        session.offlineSyncSelections = ["courses/2"]

        mockCourseList(courseList: [
            .make(id: "1", name: "course 1", tabs: []),
            .make(id: "2", name: "course 2", tabs: []),
        ])

        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: session)

        // MARK: - WHEN
        let selectedItemID = testee
            .getCourseSyncEntries()
            .map { entries in
                entries.filter { $0.selectionState == .selected }
            }
            .compactMap { $0.first?.id }
            .first()

        // MARK: - THEN
        XCTAssertCompletableSingleOutputEquals(selectedItemID, "courses/2")
        session.reset()
    }

    func testSavesSelectionState() {
        // MARK: - GIVEN
        mockCourseList(courseList: [
            .make(id: "1", name: "course 1", tabs: []),
            .make(id: "2", name: "course 2", tabs: []),
        ])

        let testee = CourseSyncSelectorInteractorLive(sessionDefaults: defaults)
        XCTAssertFinish(testee.getCourseSyncEntries().first())

        // MARK: - WHEN
        testee.setSelected(selection: .course("courses/2"), selectionState: .selected)

        // MARK: - THEN
        XCTAssertEqual(defaults.offlineSyncSelections, ["courses/2"])
    }

    func testFilterSaveWithCourseFilterDontOverwriteOtherSelections() {
        // MARK: - GIVEN
        defaults.offlineSyncSelections = ["courses/2", "courses/1/tabs/1"]

        mockCourseList(courseList: [
            .make(id: "1", name: "course 1", tabs: []),
            .make(id: "2", name: "course 2", tabs: []),
        ])

        let testee = CourseSyncSelectorInteractorLive(courseID: "1", sessionDefaults: defaults)
        XCTAssertFinish(testee.getCourseSyncEntries().first())

        // MARK: - WHEN
        testee.setSelected(selection: .course("courses/1"), selectionState: .selected)

        // MARK: - THEN
        XCTAssertEqual(defaults.offlineSyncSelections, ["courses/2", "courses/1"])
    }

    // MARK: - Helpers

    private func mockCourseList(courseList: [APICourse] = [.make(id: "1")]) {
        let courseListUseCase = GetCourseSyncSelectorCourses()
        api.mock(courseListUseCase, value: courseList)
    }

    private func mockRootFolders(courseID: String = "1", folders: [APIFolder]) {
        let foldersUseCase = GetFolderByPath(context: .course(courseID))
        api.mock(foldersUseCase, value: folders)
    }

    private func mockFolderItems(for folderID: String, folders: [APIFolder], files: [APIFile]) {
        let foldersUseCase = GetFoldersRequest(context: Context(.folder, id: folderID))
        api.mock(foldersUseCase, value: folders)

        let filesUseCase = GetFilesRequest(context: Context(.folder, id: folderID))
        api.mock(filesUseCase, value: files)
    }
}
