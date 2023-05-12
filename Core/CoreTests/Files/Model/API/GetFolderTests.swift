//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import XCTest
@testable import Core

class GetFolderTests: CoreTestCase {
    func testGetFolder() {
        let useCase = GetFolder(context: .course("1"), folderID: "1")
        XCTAssertEqual(useCase.cacheKey, "folders/1")
        XCTAssertEqual(useCase.request.path, "courses/1/folders/1")
        XCTAssertEqual(useCase.scope, .where(#keyPath(Folder.id), equals: "1"))
    }

    func testGetFolderByPath() {
        let useCase = GetFolderByPath(context: .course("1"), path: "sub")
        XCTAssertEqual(useCase.cacheKey, "courses/1/folders/by_path/sub")
        XCTAssertEqual(useCase.request.fullPath, "sub")
        XCTAssertEqual(useCase.scope, Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Folder.canvasContextID), equals: "course_1"),
                NSPredicate(key: #keyPath(Folder.path), equals: "sub"),
            ]),
            orderBy: #keyPath(Folder.id)
        ))
        XCTAssertEqual(GetFolderByPath(context: .currentUser).scope, Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Folder.canvasContextID), equals: "user_1"),
                NSPredicate(key: #keyPath(Folder.path), equals: ""),
            ]),
            orderBy: #keyPath(Folder.id)
        ))
        api.mock(useCase, value: [
            .make(context_type: "Course", context_id: "1", full_name: "m/sub", id: 2, name: "sub", parent_folder_id: 1),
        ])
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        useCase.fetch()
        let items: [Folder] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(items.first?.name, "sub")
    }

    func testGetFolderItems() {
        let useCase = GetFolderItems(folderID: "1")
        XCTAssertEqual(useCase.cacheKey, "/folder/1/items")
        XCTAssertEqual(useCase.scope, .where(
            #keyPath(FolderItem.parentFolderID), equals: "1",
            orderBy: #keyPath(FolderItem.name), naturally: true
        ))
        api.mock(GetFilesRequest(context: Context(.folder, id: "1")), value: [ .make() ])
        api.mock(GetFoldersRequest(context: Context(.folder, id: "1")), value: [ .make(id: 2, parent_folder_id: 1) ])
        useCase.fetch()
        drainMainQueue()
        let items: [FolderItem] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(items.first?.name, "File")
        XCTAssertEqual(items.last?.name, "my files")
    }

    func testGetFolders() {
        XCTAssertEqual(GetFolders(context: .course("1")).cacheKey, "courses/1/folders")
        XCTAssertEqual(GetFolders(context: .course("1")).request.context, .course("1"))
        XCTAssertEqual(GetFolders(context: .course("1")).scope, .where(
            #keyPath(Folder.canvasContextID), equals: "course_1",
            orderBy: #keyPath(Folder.name), naturally: true)
        )
        XCTAssertEqual(GetFolders(context: Context(.folder, id: "2")).scope, .where(
            #keyPath(Folder.parentFolderID), equals: "2",
            orderBy: #keyPath(Folder.name), naturally: true)
        )
    }

    func testCreateFolder() {
        let useCase = CreateFolder(context: .course("1"), name: "f", parentFolderID: "1")
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.context, .course("1"))
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        useCase.write(response: .make(), urlResponse: nil, to: databaseClient)
        let folder: FolderItem? = databaseClient.first(where: #keyPath(FolderItem.id), equals: "folder-1")
        XCTAssertEqual(folder?.name, "my files")
        XCTAssertEqual(folder?.file, nil)
        XCTAssertEqual(folder?.folder?.path, "")
    }

    func testUpdateFolder() {
        let useCase = UpdateFolder(folderID: "1", name: "f", locked: true, hidden: false, unlockAt: nil, lockAt: nil)
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.body?.locked, true)
        XCTAssertEqual(useCase.scope, .where(#keyPath(Folder.id), equals: "1"))
    }

    func testDeleteFolder() {
        let useCase = DeleteFolder(folderID: "1")
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.folderID, "1")
        XCTAssertEqual(useCase.scope, .where(#keyPath(Folder.id), equals: "1"))
    }
}
