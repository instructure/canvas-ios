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

import Foundation
import XCTest
@testable import Core

class UploadFileTests: CoreTestCase {
    func testItStartsFileUpload() {
        queueFileUpload()
        mockAPI()

        let uploadFile = UploadFile(env: environment, file: testFile)
        addOperationAndWait(uploadFile)

        let fileUploads: [FileUpload] = databaseClient.fetch()
        XCTAssertEqual(fileUploads.count, 1)
        XCTAssertEqual(fileUploads.first?.backgroundSessionID, api.identifier)
        XCTAssertEqual(fileUploads.first?.taskID, 1)
        XCTAssertEqual(backgroundAPI.uploadMocks.count, 1)
        XCTAssertEqual(backgroundAPI.uploadMocks.values.first?.resumeCount, 1)
    }

    private func queueFileUpload() {
        let info = FileInfo(url: testFile, size: 120)
        let context = ContextModel(.course, id: "1")
        Assignment.make(["id": "1"])
        let queue = QueueFileUpload(fileInfo: info, context: context, assignmentID: "1", userID: "2", env: environment)
        addOperationAndWait(queue)
    }

    private func mockAPI() {
        let body = PostFileUploadTargetRequest.Body(
            name: testFile.lastPathComponent,
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .submission(courseID: "1", assignmentID: "1"),
            body: body
        )
        let response = PostFileUploadTargetRequest.Response.init(upload_url: URL(string: "s3://somewhere.com/bucket/1")!, upload_params: [:])
        api.mock(request, value: response)
    }
}
