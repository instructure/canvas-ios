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

    func testReplacesStudioIFrames() throws {
        let videoURL = URL(string: "/video.mp4")!
        let videoPosterURL = URL(string: "/video.png")!
        let mimeType = "video/mp4"
        let subtitle1URL = URL(string: "/en.srt")!
        let subtitle2URL = URL(string: "/hu.srt")!

        let htmlFileURL = workingDirectory.appending(path: "body.html")
        try StudioTestData.html.write(
            to: htmlFileURL,
            atomically: false,
            encoding: .utf8
        )

        let iframe = StudioIFrame(
            mediaLTILaunchID: StudioTestData.ltiLaunchID,
            sourceHtml: StudioTestData.iframe
        )
        let offlineVideo = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: videoURL,
            videoPosterLocation: videoPosterURL,
            videoMimeType: mimeType,
            captionLocations: [subtitle1URL, subtitle2URL]
        )

        // WHEN
        try StudioIFrameReplaceInteractorLive().replaceStudioIFrames(
            inHtmlAtURL: htmlFileURL,
            iframes: [iframe],
            offlineVideos: [offlineVideo]
        )

        let expectedResult = """
        <p>
        <video controls playsinline preload="auto" poster="/video.png">
          <source src="\(videoURL)" type="\(mimeType)" />
          <track kind="captions" src="\(subtitle1URL)" srclang="en" />
          <track kind="captions" src="\(subtitle2URL)" srclang="hu" />
        </video>
        </p>
        """
        let modifiedHtmlData = try Data(contentsOf: htmlFileURL)

        XCTAssertEqual(
            String(data: modifiedHtmlData, encoding: .utf8),
            expectedResult
        )
    }
}
