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

@testable import Core
import XCTest

class StudioVideoCacheInteractorTests: CoreTestCase {
    private lazy var videoURL = workingDirectory.appending(
        path: "test.mp4",
        directoryHint: .notDirectory
    )
    let testee = StudioVideoCacheInteractor()

    func testNotExistingFile() {
        XCTAssertFalse(testee.isVideoDownloaded(
            videoLocation: videoURL,
            expectedSize: 1
        ))
    }

    func testExistingFileNonMatchingSize() throws {
        try makeFile(size: 1)

        XCTAssertFalse(testee.isVideoDownloaded(
            videoLocation: videoURL,
            expectedSize: 2
        ))
    }

    func testExistingFileMatchingEmptySize() throws {
        try makeFile(size: 0)

        XCTAssertTrue(testee.isVideoDownloaded(
            videoLocation: videoURL,
            expectedSize: 0
        ))
    }

    func testExistingFileMatchingValidSize() throws {
        try makeFile(size: 6)

        XCTAssertTrue(testee.isVideoDownloaded(
            videoLocation: videoURL,
            expectedSize: 6
        ))
    }

    private func makeFile(size: Int) throws {
        try Data(repeating: 0, count: size).write(to: videoURL)
    }
}
