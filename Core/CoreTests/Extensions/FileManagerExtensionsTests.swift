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

import Combine
@testable import Core
import TestsFoundation
import XCTest

class FileManagerExtensionsTests: CoreTestCase {
    let fileManager = FileManager.default

    private var subscriptions: [AnyCancellable] = []

    func testRemoveItemPublisher() {
        let fileURL = URL.Directories.documents.appendingPathComponent("test.txt")
        fileManager.createFile(atPath: fileURL.path, contents: "test".data(using: .utf8))

        XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path))

        fileManager.removeItemPublisher(at: fileURL).sink(receiveCompletion: { [fileManager] _ in
            XCTAssertFalse(fileManager.fileExists(atPath: fileURL.path))
        }, receiveValue: { })
        .store(in: &subscriptions)
    }
}
