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

class StudioOfflineVideoTests: XCTestCase {
    enum TestData {
        static let ltiLaunchID = "testLaunchID"
        static let videoMimeType = "video/mp4"
        static let folder = "/folder"
        static let videoFileName = "video.mp4"
        static let posterFileName = "video.mp4"
        static let captionFileName = "en.srt"
    }

    func testMakesRelativeURLs() throws {
        let testee = try StudioOfflineVideo(
            ltiLaunchID: TestData.ltiLaunchID,
            videoLocation: URL(string: "\(TestData.folder)/\(TestData.videoFileName)")!,
            videoPosterLocation: URL(string: "\(TestData.folder)/\(TestData.posterFileName)")!,
            videoMimeType: TestData.videoMimeType,
            captionLocations: [URL(string: "\(TestData.folder)/\(TestData.captionFileName)")!],
            baseURL: URL(string: TestData.folder)!
        )

        XCTAssertEqual(testee.ltiLaunchID, TestData.ltiLaunchID)
        XCTAssertEqual(testee.videoMimeType, TestData.videoMimeType)
        XCTAssertEqual(testee.videoRelativePath, TestData.videoFileName)
        XCTAssertEqual(testee.videoPosterRelativePath, TestData.posterFileName)
        XCTAssertEqual(testee.captions[0].relativePath, TestData.captionFileName)
        XCTAssertEqual(testee.captions[0].languageCode, "en")
    }
}
