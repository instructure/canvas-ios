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

class StudioIFrameReplaceInteractorLiveTests: CoreTestCase {
    private enum TestData {
        static let videoURL = URL(string: "/video.mp4")!
        static let videoPosterURL = URL(string: "/video.png")!
        static let mimeType = "video/mp4"
        static let subtitle1URL = URL(string: "/en.srt")!
        static let subtitle2URL = URL(string: "/hu.srt")!
        static let iframe = StudioIFrame(
            mediaLTILaunchID: StudioTestData.ltiLaunchID,
            sourceHtml: StudioTestData.iframe
        )

    }
    lazy var htmlFileURL = workingDirectory.appending(path: "body.html")

    override func setUpWithError() throws {
        try super.setUpWithError()

        try StudioTestData.html.write(
            to: htmlFileURL,
            atomically: false,
            encoding: .utf8
        )
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(atPath: htmlFileURL.path)
        try super.tearDownWithError()
    }

    func testReplacesStudioIFrames() throws {
        let offlineVideo = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: TestData.videoURL,
            videoPosterLocation: TestData.videoPosterURL,
            videoMimeType: TestData.mimeType,
            captionLocations: [TestData.subtitle1URL, TestData.subtitle2URL]
        )

        // WHEN
        try StudioIFrameReplaceInteractorLive().replaceStudioIFrames(
            inHtmlAtURL: htmlFileURL,
            iframes: [TestData.iframe],
            offlineVideos: [offlineVideo]
        )

        let expectedResult = """
        <p>
        <video controls playsinline preload="auto" poster="/video.png">
          <source src="\(TestData.videoURL)" type="\(TestData.mimeType)" />
          <track kind="captions" src="\(TestData.subtitle1URL)" srclang="en" />
          <track kind="captions" src="\(TestData.subtitle2URL)" srclang="hu" />
        </video>
        </p>
        """
        let modifiedHtmlData = try Data(contentsOf: htmlFileURL)

        XCTAssertEqual(
            String(data: modifiedHtmlData, encoding: .utf8),
            expectedResult
        )
    }

    func testReplacesStudioIFramesWithoutPosterFile() throws {
        let offlineVideo = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: TestData.videoURL,
            videoPosterLocation: nil,
            videoMimeType: TestData.mimeType,
            captionLocations: [TestData.subtitle1URL, TestData.subtitle2URL]
        )

        // WHEN
        try StudioIFrameReplaceInteractorLive().replaceStudioIFrames(
            inHtmlAtURL: htmlFileURL,
            iframes: [TestData.iframe],
            offlineVideos: [offlineVideo]
        )

        let expectedResult = """
        <p>
        <video controls playsinline preload="auto">
          <source src="\(TestData.videoURL)" type="\(TestData.mimeType)" />
          <track kind="captions" src="\(TestData.subtitle1URL)" srclang="en" />
          <track kind="captions" src="\(TestData.subtitle2URL)" srclang="hu" />
        </video>
        </p>
        """
        let modifiedHtmlData = try Data(contentsOf: htmlFileURL)

        XCTAssertEqual(
            String(data: modifiedHtmlData, encoding: .utf8),
            expectedResult
        )
    }

    func testErrorDescription() {
        XCTAssertEqual(
            StudioIFrameReplaceError.failedToConvertDataToString.localizedDescription,
            "StudioIFrameReplaceError.failedToConvertDataToString"
        )
    }
}
