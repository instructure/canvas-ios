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

class CreateFileSubmissionsTests: CoreTestCase {
    func testItStartsNextUpload() {
        let next = createNextFileUpload()
        mockAPI(fileUpload: next)

        let operation = CreateFileSubmissions(env: environment, userID: "1")
        addOperationAndWait(operation)

        databaseClient.refresh()
        XCTAssertEqual(next.backgroundSessionID, api.identifier)
        XCTAssertEqual(next.taskID, 1)
    }

    func testItSubmitsReadySubmissions() {
        let next = createNextFileUpload()
        next.completed = true
        try! databaseClient.save()

        let operation = CreateFileSubmissions(env: environment, userID: "1")
        addOperationAndWait(operation)
    }

    private func createNextFileUpload() -> FileUpload {
        let fileSubmission = FileSubmission.make()
        let completed = FileUpload.make(["completed": true])
        fileSubmission.addToFileUploads(completed)
        let next = FileUpload.make(["completed": false, "error": nil, "url": testFile])
        fileSubmission.addToFileUploads(next)
        try! databaseClient.save()
        return next
    }

    private func mockAPI(fileUpload: FileUpload) {
        let body = PostFileUploadTargetRequest.Body(
            name: fileUpload.url.lastPathComponent,
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
