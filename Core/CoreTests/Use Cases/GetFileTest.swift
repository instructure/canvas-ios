//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class GetFileTests: CoreTestCase {
    func testItCreatesFile() {
        let dateString = Date().isoString()
        let request = GetFileRequest(context: ContextModel(.course, id: "1"), fileID: "2")
        let apiFile = APIFile.make([
            "id": "2",
            "uuid": "test-uuid-1234",
            "folder_id": "1",
            "display_name": "GetFileTest",
            "filename": "GetFileTest.pdf",
            "content-type": "application/pdf",
            "url": "https://canvas.instructure.com/files/2/download",
            "size": 2048,
            "created_at": dateString,
            "updated_at": dateString,
            "modified_at": dateString,
            "mime_class": "PDF",
        ])
        api.mock(request, value: apiFile, response: nil, error: nil)

        let getFile = GetFile(courseID: "1", fileID: "2", env: environment)
        addOperationAndWait(getFile)

        XCTAssertEqual(getFile.errors.count, 0)
        let files: [File] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(files.count, 1)
        let file = files.first!
        XCTAssertEqual(file.id, "2")
        XCTAssertEqual(file.uuid, "test-uuid-1234")
        XCTAssertEqual(file.folderID, "1")
        XCTAssertEqual(file.displayName, "GetFileTest")
        XCTAssertEqual(file.filename, "GetFileTest.pdf")
        XCTAssertEqual(file.contentType, "application/pdf")
        XCTAssertEqual(file.url.absoluteString, "https://canvas.instructure.com/files/2/download")
        XCTAssertEqual(file.size, 2048)
        XCTAssertEqual(file.createdAt.isoString(), dateString)
        XCTAssertEqual(file.updatedAt!.isoString(), dateString)
        XCTAssertFalse(file.locked)
        XCTAssertFalse(file.hidden)
        XCTAssertFalse(file.hiddenForUser)
        XCTAssertEqual(file.mimeClass, "PDF")
        XCTAssertFalse(file.lockedForUser)
    }
}
