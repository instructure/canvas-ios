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

class FileUploadTests: CoreTestCase {

    func testSaveFileUpload() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        let assignmentID = "1"
        let size: Int64 = 1024
        let info = FileInfo(url: url, size: size)
        let c = ContextModel(.course, id: "1")
        Assignment.make(["id": assignmentID])
        let queueToUpload = QueueFileUpload(fileInfo: info, context: c, assignmentID: assignmentID, userID: "1", env: environment)

        addOperationAndWait(queueToUpload)

        let files: [FileUpload] = environment.database.mainClient.fetch()
        guard let file = files.first else { XCTFail(); return }
        XCTAssertEqual(file.url, url)
        XCTAssertEqual(file.submission?.assignment.id, "1")
        XCTAssertEqual(file.context as? ContextModel, c)
        XCTAssertEqual(file.size, size)
    }
}
