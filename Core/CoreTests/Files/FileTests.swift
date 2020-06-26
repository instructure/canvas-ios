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

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class FileTests: CoreTestCase {
    func testSave() {
        let item = APIFile.make(id: "1", usage_rights: .make(use_justification: .fair_use))
        File.save(item, in: databaseClient)
        let files: [File] = databaseClient.fetch()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.filename, item.filename)
        XCTAssertEqual(files.first?.usageRights?.useJustification, .fair_use)
    }

    func testIcon() {
        XCTAssertEqual(File.make(from: .make(contentType: "audio/x-m4a", mime_class: "audio")).icon, UIImage.icon(.audio))
        XCTAssertEqual(File.make(from: .make(contentType: "audio/x-m4a", mime_class: "file")).icon, UIImage.icon(.audio))
        XCTAssertEqual(File.make(from: .make(contentType: "application/word", mime_class: "doc")).icon, UIImage.icon(.document))
        XCTAssertEqual(File.make(from: .make(contentType: "image/jpeg", mime_class: "image")).icon, UIImage.icon(.image))
        XCTAssertEqual(File.make(from: .make(contentType: "image/heic", mime_class: "file")).icon, UIImage.icon(.image))
        XCTAssertEqual(File.make(from: .make(contentType: "application/pdf", mime_class: "pdf")).icon, UIImage.icon(.pdf))
        XCTAssertEqual(File.make(from: .make(contentType: "video/x-m4v", mime_class: "video")).icon, UIImage.icon(.video))
        XCTAssertEqual(File.make(from: .make(contentType: "video/x-m4v", mime_class: "file")).icon, UIImage.icon(.video))
        XCTAssertEqual(File.make(from: .make(contentType: "bogus", mime_class: "bogus")).icon, UIImage.icon(.document))
    }

    func testIsUploading() {
        let file = File.make()
        file.taskID = nil
        XCTAssertFalse(file.isUploading)

        file.taskID = "1"
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
