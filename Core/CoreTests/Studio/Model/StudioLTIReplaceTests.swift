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

class StudioLTIReplaceTests: XCTestCase {

    func testReplacesStudioIFrame() {
        let iframe = "<iframe param=1></iframe>"
        let html = """
        <p>Test<br/>
        \(iframe)
        </p>
        """
        let videoURL = URL(string: "/video")!
        let mimeType = "video/mp4"
        let subtitleEnglish = URL(string: "/en.srt")!
        let subtitleHungarian = URL(string: "/hu.srt")!

        let result = StudioIFrameReplaceInteractor.replaceStudioIFrame(
            html: html,
            iFrame: iframe,
            video: videoURL,
            videoMimeType: mimeType,
            captions: [subtitleEnglish, subtitleHungarian]
        )

        let expectedResult = """
        <p>Test<br/>
        <video>
          <source src="\(videoURL)" type="\(mimeType)" />
          <track kind="captions" src="\(subtitleEnglish)" srclang="en"/>
          <track kind="captions" src="\(subtitleHungarian)" srclang="hu"/>
        </video>
        </p>
        """
        XCTAssertEqual(result, expectedResult)
    }
}
