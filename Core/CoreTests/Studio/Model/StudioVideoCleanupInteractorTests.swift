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

class StudioVideoCleanupInteractorTests: CoreTestCase {
    private enum TestConstants {
        static let video1ID = "1"
        static let video2ID = "2"
    }

    func testRemovesNotNeededStudioFolders() throws {
        let usedVideoFolderURL = workingDirectory.appending(
            path: TestConstants.video1ID,
            directoryHint: .isDirectory
        )
        let usedVideoURL = usedVideoFolderURL.appending(
            path: "\(TestConstants.video1ID).mpg",
            directoryHint: .notDirectory
        )
        let notUsedVideoFolderURL = workingDirectory.appending(
            path: TestConstants.video2ID,
            directoryHint: .isDirectory
        )
        let notUsedVideoURL = notUsedVideoFolderURL.appending(
            path: "\(TestConstants.video2ID).mpg",
            directoryHint: .notDirectory
        )
        let folderLikeFile = workingDirectory.appending(
            path: "\(TestConstants.video1ID).\(TestConstants.video2ID)",
            directoryHint: .notDirectory
        )

        try FileManager.default.createDirectory(at: usedVideoFolderURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: notUsedVideoFolderURL, withIntermediateDirectories: true)

        XCTAssertTrue(FileManager.default.createFile(atPath: usedVideoURL.path(), contents: nil))
        XCTAssertTrue(FileManager.default.createFile(atPath: notUsedVideoURL.path(), contents: nil))
        XCTAssertTrue(FileManager.default.createFile(atPath: folderLikeFile.path(), contents: nil))

        let apiMediaItems: [APIStudioMediaItem] = [
            .init(
                id: ID(TestConstants.video1ID),
                lti_launch_id: "lti_\(TestConstants.video1ID)",
                title: "",
                mime_type: "",
                size: 1,
                url: URL(string: "/")!,
                captions: []
            ),
            .init(
                id: ID(TestConstants.video2ID),
                lti_launch_id: "lti_\(TestConstants.video2ID)",
                title: "",
                mime_type: "",
                size: 1,
                url: URL(string: "/")!,
                captions: []
            )
        ]

        // WHEN
        let testee = StudioVideoCleanupInteractor(
            offlineStudioDirectory: workingDirectory
        ).removeNoLongerNeededVideos(
            allMediaItemsOnAPI: apiMediaItems,
            mediaLTIIDsUsedInOfflineMode: ["lti_\(TestConstants.video1ID)"]
        )

        // THEN
        XCTAssertFinish(testee)
        XCTAssertEqual(FileManager.default.fileExists(atPath: usedVideoURL.path()), true)
        XCTAssertEqual(FileManager.default.fileExists(atPath: notUsedVideoURL.path()), false)
        XCTAssertEqual(FileManager.default.fileExists(atPath: folderLikeFile.path()), true)
    }
}
