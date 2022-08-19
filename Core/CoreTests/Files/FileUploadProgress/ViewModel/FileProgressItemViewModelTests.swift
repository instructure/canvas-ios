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

import Core
import XCTest

class FileProgressItemViewModelTests: CoreTestCase {

    func testStateIfFileHasIdAndError() {
        let file = makeFile()
        file.uploadError = "error"
        file.id = "testId"

        let testee = FileProgressItemViewModel(file: file, onRemove: {})
        XCTAssertEqual(testee.state, .completed)
    }

    func testA11yLabelWhileWaiting() {
        let file = makeFile()
        let testee = FileProgressItemViewModel(file: file, onRemove: {})
        XCTAssertEqual(testee.accessibilityLabel, "File fileName.txt size 10 bytes. ")
    }

    func testA11yLabelDuringUpload() {
        let file = makeFile()
        file.bytesSent = 3
        file.taskID = ""
        let testee = FileProgressItemViewModel(file: file, onRemove: {})
        XCTAssertEqual(testee.accessibilityLabel, "File fileName.txt size 10 bytes. Upload in progress 30%")
    }

    func testA11yLabelOnError() {
        let file = makeFile()
        file.uploadError = "error"
        let testee = FileProgressItemViewModel(file: file, onRemove: {})
        XCTAssertEqual(testee.accessibilityLabel, "File fileName.txt size 10 bytes. Upload failed.")
    }

    func testA11yLabelWhenCompleted() {
        let file = makeFile()
        file.id = "5"
        let testee = FileProgressItemViewModel(file: file, onRemove: {})
        XCTAssertEqual(testee.accessibilityLabel, "File fileName.txt size 10 bytes. Upload completed.")
    }

    // MARK: Helpers

    @discardableResult
    private func makeFile() -> File {
        let file = databaseClient.insert() as File
        file.batchID = "testBatch"
        file.size = 10
        file.localFileURL = URL(string: "/fileName.txt")!
        file.setUser(session: environment.currentSession!)
        return file
    }
}
