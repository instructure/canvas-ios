//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import TestsFoundation
import XCTest

class FileSubmissionCleanupTests: CoreTestCase {
    private let tempFileURL = URL.Directories.temporary.appendingPathComponent("FileUploadTargetRequesterTests.txt")

    override func setUp() {
        super.setUp()
        FileManager.default.createFile(atPath: tempFileURL.path, contents: "tst".data(using: .utf8), attributes: nil)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempFileURL)
        super.tearDown()
    }

    func testDeletesFile() {
        // MARK: - GIVEN

        let testee = FileSubmissionCleanup(context: databaseClient)
        let submission: FileSubmission = databaseClient.insert()
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission
        item.localFileURL = tempFileURL

        // MARK: - WHEN

        let completionEvent = expectation(description: "completion event fire")
        let subscription = testee
            .clean(fileSubmissionID: submission.objectID)
            .sink { _ in
                completionEvent.fulfill()
            } receiveValue: { _ in }

        // MARK: - THEN

        waitForExpectations(timeout: 1)
        FileManager.default.fileExists(atPath: tempFileURL.path)

        subscription.cancel()
    }
}
