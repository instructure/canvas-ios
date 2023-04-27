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

class CourseSyncSelectorInteractorLiveTests: CoreTestCase {
    func testCourseList() {
        let testee = CourseSyncSelectorInteractorLive()
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

    /*
     func testTabList() {
         let testee = CourseSyncSelectorInteractorLive()
         let expectation = expectation(description: "Publisher sends value")

         mockCourseList(tabList: [
             .make(id: "assignments", label: "Assignments", hidden: false),
             .make(id: "pages", label: "Pages", hidden: false),
             .make(id: "files", label: "Files", hidden: false),
             .make(id: "quizzes", label: "Quizzes", hidden: false),
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
         XCTAssertEqual(entries[0].tabs.count, 3)
         XCTAssertFalse(entries[0].tabs.contains(where: { tab in
             tab.name == "quizzes"
         }))
         subscription.cancel()
     }
     */

    func testFileList() {
        let testee = CourseSyncSelectorInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        let rootFolder = APIFolder.make(context_type: "Course", context_id: 1, files_count: 1, id: 0)
        let rootFolderFile = APIFile.make(id: 0, folder_id: 0, display_name: "root-file-1")

        let folder1 = APIFolder.make(id: 1, parent_folder_id: 0)
        let folder1File = APIFile.make(id: 1, folder_id: 1, display_name: "folder-1-file")

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [folder1], files: [rootFolderFile])
        mockFolderItems(for: "1", folders: [], files: [folder1File])
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
        XCTAssertEqual(entries[0].files.count, 2)
        XCTAssertEqual(entries[0].files[0].name, "root-file-1")
        XCTAssertEqual(entries[0].files[1].name, "folder-1-file")
        subscription.cancel()
    }

    func testDefaultSelection() {
        let testee = CourseSyncSelectorInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        mockCourseList(
            tabList: [.make(id: "assignments", label: "Assignments", hidden: false)]
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
        XCTAssertTrue(entries[0].isSelected)
        XCTAssertEqual(entries[0].tabs.count, 1)
        XCTAssertEqual(entries[0].files.count, 2)
        XCTAssertEqual(entries[0].selectedTabsCount, entries[0].tabs.count)
        XCTAssertEqual(entries[0].selectedFilesCount, entries[0].files.count)
        subscription.cancel()
    }

    func testCourseSelection() {}

    func testTabSelection() {
        var entry = CourseSyncEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: []
        )
        XCTAssertEqual(entry.isSelected, true)
        XCTAssertEqual(entry.selectedTabsCount, 2)

        entry.selectTab(index: 0, isSelected: false)
        XCTAssertEqual(entry.isSelected, true)
        XCTAssertEqual(entry.selectedTabsCount, 1)

        entry.selectTab(index: 1, isSelected: false)
        XCTAssertEqual(entry.isSelected, false)
        XCTAssertEqual(entry.selectedTabsCount, 0)

        entry.selectCourse(isSelected: true)
        XCTAssertEqual(entry.selectedTabsCount, 2)
    }

    func testFileSelection() {}

    private func mockCourseList(
        context: Context = .course("1"),
        courseList: [APICourse] = [.make(id: "1")],
        tabList: [APITab] = []
    ) {
        let courseListUseCase = GetCourseListCourses(enrollmentState: .active)
        api.mock(courseListUseCase, value: courseList)

        let tabListUseCase = GetContextTabs(context: context)
        api.mock(tabListUseCase, value: tabList)
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
