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

class CourseSyncEntryComposerInteractorLiveTests: CoreTestCase {
    private lazy var updatedAt = Date.init(timeIntervalSince1970: 1000)
    private let rootFolder = APIFolder.make(
        context_type: "Course",
        context_id: "course-id-1",
        files_count: 1,
        id: 0
    )
    private lazy var rootFolderFile = APIFile.make(
        id: "file-1",
        folder_id: 0,
        display_name: "file-displayname-1",
        filename: "file-name-1",
        size: 1000,
        updated_at: updatedAt
    )

    func testFileTabAndFilesAreMapped() {
        let testee = CourseSyncEntryComposerInteractorLive()
        let course = CourseSyncSelectorCourse.save(
            .make(
                id: "course-id-1",
                name: "course-name-1",
                tabs: [
                    .make(id: "files", label: "tab-files")
                ]
            ),
            in: databaseClient
        )

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [], files: [rootFolderFile])

        XCTAssertSingleOutputEquals(
            testee.composeEntry(from: course, useCache: false),
            CourseSyncEntry(
                name: "course-name-1",
                id: "courses/course-id-1",
                tabs: [
                    .init(id: "courses/course-id-1/tabs/files", name: "tab-files", type: .files)
                ],
                files: [
                    .init(
                        id: "courses/course-id-1/files/file-1",
                        displayName: "file-displayname-1",
                        fileName: "file-name-1",
                        url: URL(string: "https://canvas.instructure.com/files/1/download")!,
                        mimeClass: "image",
                        updatedAt: updatedAt,
                        bytesToDownload: 1000
                    ),
                ]
            )
        )
    }

    func testFilesNotMappedWithoutFilesTab() {
        let testee = CourseSyncEntryComposerInteractorLive()
        let course = CourseSyncSelectorCourse.save(
            .make(
                id: "course-id-1",
                name: "course-name-1",
                tabs: []
            ),
            in: databaseClient
        )

        mockRootFolders(folders: [rootFolder])
        mockFolderItems(for: "0", folders: [], files: [rootFolderFile])

        XCTAssertSingleOutputEquals(
            testee.composeEntry(from: course, useCache: false),
            CourseSyncEntry(
                name: "course-name-1",
                id: "courses/course-id-1",
                tabs: [],
                files: []
            )
        )
    }

    private func mockRootFolders(courseID: String = "course-id-1", folders: [APIFolder]) {
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
