//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation
@testable import Core

class UserFilesTests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { UserFilesTests.self }

    lazy var root = APIFileFolder.make()

    override func setUp() {
        super.setUp()
        mockBaseRequests()
        mockData(GetAccountHelpLinksRequest(), value: nil)
        mockData(GetGlobalNavExternalToolsRequest(), value: [])
        mockData(GetContextFolderHierarchyRequest(context: .user("self")), value: [root])
        mockData(ListFoldersRequest(context: Context(.folder, id: root.id.value)), value: [])
        mockData(ListFilesRequest(context: Context(.folder, id: root.id.value)), value: [])
        mockData(GetFolderRequest(context: nil, id: root.id.value), value: root)
        sleep(1)

        logIn()
        Dashboard.profileButton.tap()
        Profile.filesButton.tap()
    }

    func mockUpload(_ uploadTrigger: () -> Void) {
        let uploadExpectation = XCTestExpectation(description: "file was uploaded")
        let uploadTarget = FileUploadTarget.make()

        mockURL(root.files_url.rawValue) { _ in
            app.find(label: "Uploading").waitToExist()
            uploadExpectation.fulfill()
            return (try? JSONEncoder().encode(uploadTarget))!
        }
        let file = APIFile.make()
        mockURL(uploadTarget.upload_url, data: try? JSONEncoder().encode(file))
        mockData(GetFileRequest(context: nil, fileID: file.id.value, include: []), value: file)

        uploadTrigger()

        app.find(label: "Uploading").waitToVanish()
        wait(for: [uploadExpectation], timeout: 30)
    }

    func testAddFileAudio() {
        FilesList.addButton.tap()
        app.find(label: "Add File").tap()
        allowAccessToMicrophone {
            app.find(label: "Record Audio").tap()
        }
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()

        mockUpload {
            AudioRecorder.sendButton.tap()
        }
    }

    func testAddFileFiles() {
        FilesList.addButton.tap()
        app.find(label: "Add File").tap()
        allowAccessToPhotos {
            app.find(label: "Choose From Library").tap()
        }

        let photo = app.find(labelContaining: "Photo, ")
        app.find(label: "All Photos").tapUntil { photo.exists }
        mockUpload {
            photo.tap()
        }
    }
}
