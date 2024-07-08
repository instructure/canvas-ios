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

class StudioIFrameReplaceInteractorTests: AbstractStudioTest {

    func testReplacesStudioIFrame() throws {
        let videoURL = URL(string: "/video.mp4")!
        let videoPosterURL = URL(string: "/video.png")!
        let mimeType = "video/mp4"
        let subtitle1URL = URL(string: "/en.srt")!
        let subtitle2URL = URL(string: "/hu.srt")!
        let studioOfflineVideo = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.mediaID,
            videoLocation: videoURL,
            videoPosterLocation: videoPosterURL,
            videoMimeType: mimeType,
            captionLocations: [subtitle1URL, subtitle2URL]
        )

        let result = StudioIFrameReplaceInteractor().replaceStudioIFrame(
            html: StudioTestData.html,
            iFrameHtml: StudioTestData.iframe,
            studioVideo: studioOfflineVideo
        )

        let expectedResult = """
        <p>Test<br/>
        <video>
          <source src="\(videoURL)" type="\(mimeType)" />
          <track kind="captions" src="\(subtitle1URL)" srclang="en"/>
          <track kind="captions" src="\(subtitle2URL)" srclang="hu"/>
        </video>
        </p>
        """
        XCTAssertEqual(result, expectedResult)
    }
}
