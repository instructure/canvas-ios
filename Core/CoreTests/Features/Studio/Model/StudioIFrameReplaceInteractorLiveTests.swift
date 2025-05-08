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
    private struct TestData {
        let folder = "StudioIFrameReplaceInteractorLiveTests"
        let videoFileName = "video.mp4"
        let videoURL: URL
        let videoPosterFileName = "video.png"
        let videoPosterURL: URL
        let mimeType = "video/mp4"
        let subtitle1FileName = "en.srt"
        let subtitle1URL: URL
        let subtitle2FileName = "hu.srt"
        let subtitle2URL: URL
        let iframe = StudioIFrame(
            mediaLTILaunchID: StudioTestData.ltiLaunchID,
            sourceHtml: StudioTestData.iframe
        )

        init(workingDirectory: URL) {
            videoURL = workingDirectory.appending(path: "\(folder)/\(videoFileName)")
            videoPosterURL = workingDirectory.appending(path: "\(folder)/\(videoPosterFileName)")
            subtitle1URL = workingDirectory.appending(path: "\(folder)/\(subtitle1FileName)")
            subtitle2URL = workingDirectory.appending(path: "\(folder)/\(subtitle2FileName)")
        }
    }
    private lazy var testData = TestData(workingDirectory: workingDirectory)
    private lazy var htmlFileURL = workingDirectory.appending(path: "\(testData.folder)/body.html")

    override func setUpWithError() throws {
        try super.setUpWithError()

        try FileManager.default.createDirectory(
            at: htmlFileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
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
        let offlineVideo = try StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: testData.videoURL,
            videoPosterLocation: testData.videoPosterURL,
            videoMimeType: testData.mimeType,
            captionLocations: [testData.subtitle1URL, testData.subtitle2URL],
            baseURL: workingDirectory
        )

        // WHEN
        try StudioIFrameReplaceInteractorLive().replaceStudioIFrames(
            inHtmlAtURL: htmlFileURL,
            iframes: [testData.iframe],
            offlineVideos: [offlineVideo]
        )

        let expectedResult = """
        <p>
        <video controls playsinline preload="auto" poster="\(offlineVideo.videoPosterRelativePath!)">
          <source src="\(offlineVideo.videoRelativePath)" type="\(testData.mimeType)" />
          <track kind="captions" src="\(offlineVideo.captions[0].relativePath)" srclang="en" />
          <track kind="captions" src="\(offlineVideo.captions[1].relativePath)" srclang="hu" />
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
        let offlineVideo = try StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: testData.videoURL,
            videoPosterLocation: nil,
            videoMimeType: testData.mimeType,
            captionLocations: [testData.subtitle1URL, testData.subtitle2URL],
            baseURL: workingDirectory
        )

        // WHEN
        try StudioIFrameReplaceInteractorLive().replaceStudioIFrames(
            inHtmlAtURL: htmlFileURL,
            iframes: [testData.iframe],
            offlineVideos: [offlineVideo]
        )

        let expectedResult = """
        <p>
        <video controls playsinline preload="auto">
          <source src="\(offlineVideo.videoRelativePath)" type="\(testData.mimeType)" />
          <track kind="captions" src="\(offlineVideo.captions[0].relativePath)" srclang="en" />
          <track kind="captions" src="\(offlineVideo.captions[1].relativePath)" srclang="hu" />
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
            StudioIFrameReplaceError.failedToConvertDataToString.debugDescription,
            "StudioIFrameReplaceError.failedToConvertDataToString"
        )
    }
}
