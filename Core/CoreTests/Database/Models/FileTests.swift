//
// Copyright (C) 2019-present Instructure, Inc.
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
import TestsFoundation

class FileTests: CoreTestCase {
    func testSave() {
        let item = APIFile.make(id: "1")
        XCTAssertNoThrow(try File.save(item, in: databaseClient))
        let files: [File] = databaseClient.fetch()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.filename, item.filename)
    }

    func testIcon() {
        XCTAssertEqual(File.make([ "mimeClass": "audio" ]).icon, UIImage.icon(.audio))
        XCTAssertEqual(File.make([ "mimeClass": "video" ]).icon, UIImage.icon(.video))
        XCTAssertEqual(File.make([ "mimeClass": "pdf" ]).icon, UIImage.icon(.pdf))
        XCTAssertEqual(File.make([ "mimeClass": "doc" ]).icon, UIImage.icon(.document))
        XCTAssertEqual(File.make([ "mimeClass": "bogus" ]).icon, UIImage.icon(.document))
    }

    func testIsUploading() {
        let file = File.make()
        file.taskID = nil
        XCTAssertFalse(file.isUploading)

        file.taskID = 1
        XCTAssertTrue(file.isUploading)
    }

    func testIsUploaded() {
        let file = File.make()
        file.id = nil
        XCTAssertFalse(file.isUploaded)

        file.id = "1"
        XCTAssertTrue(file.isUploaded)
    }

    func testPrepareForSubmission() {
        let file = File.make()
        file.prepareForSubmission(courseID: "11", assignmentID: "22")
        XCTAssertEqual(file.courseID, "11")
        XCTAssertEqual(file.assignmentID, "22")
    }

    func testMarkSubmitted() {
        let file = File.make()
        file.prepareForSubmission(courseID: "1", assignmentID: "2")
        file.markSubmitted()
        XCTAssertNil(file.courseID)
        XCTAssertNil(file.assignmentID)
    }
}
