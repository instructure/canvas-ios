//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import Combine
import XCTest
@testable import Core

class FilePickerInteractorLiveTests: CoreTestCase {
    var testee: FilePickerInteractorLive!

    func testFilePickerRootFolder() {
        let expectation = self.expectation(description: "getFolderItems")
        var subscriptions: [AnyCancellable] = []
        let rootFolderRequest = GetContextFolderHierarchyRequest(context: .currentUser, fullPath: "")
        let rootFolderResponse = [APIFolder.make(id: "1")]
        api.mock(rootFolderRequest, value: rootFolderResponse)
        let fileListRequest = GetFilesRequest(context: Context(.folder, id: "1"))
        let fileListResponse = [APIFile.make(id: "2")]
        api.mock(fileListRequest, value: fileListResponse)
        let folderListRequest = GetFoldersRequest(context: Context(.folder, id: "1"))
        let folderListResponse = [APIFolder.make(id: "3", parent_folder_id: "1")]
        api.mock(folderListRequest, value: folderListResponse)

        testee = FilePickerInteractorLive(folderId: nil)
        var folderItems: [FolderItem] = []

        testee.folderItems
            .sink(receiveCompletion: { _ in }, receiveValue: { items in
                folderItems = items
                if !items.isEmpty {
                    expectation.fulfill()
                }
            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(folderItems.count, 2)
        XCTAssertEqual(folderItems.map { $0.id }, fileListResponse.map { "file-\($0.id.value)" } + folderListResponse.map { "folder-\($0.id.value)" })
    }

    func testFilePickerCustomFolder() {
        let expectation = self.expectation(description: "getFolderItems")
        var subscriptions: [AnyCancellable] = []
        let fileListRequest = GetFilesRequest(context: Context(.folder, id: "1"))
        let fileListResponse = [APIFile.make(id: "2")]
        api.mock(fileListRequest, value: fileListResponse)
        let folderListRequest = GetFoldersRequest(context: Context(.folder, id: "1"))
        let folderListResponse = [APIFolder.make(id: "3", parent_folder_id: "1")]
        api.mock(folderListRequest, value: folderListResponse)

        testee = FilePickerInteractorLive(folderId: "1")
        var folderItems: [FolderItem] = []

        testee.folderItems
            .sink(receiveCompletion: { _ in }, receiveValue: { items in
                folderItems = items
                if !items.isEmpty {
                    expectation.fulfill()
                }
            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(folderItems.count, 2)
        XCTAssertEqual(folderItems.map { $0.id }, fileListResponse.map { "file-\($0.id.value)" } + folderListResponse.map { "folder-\($0.id.value)" })
    }
}
