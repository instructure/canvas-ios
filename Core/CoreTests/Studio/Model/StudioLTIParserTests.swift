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

class StudioLTIParserTests: XCTestCase {
    private static let mediaID = "65a145cf-f645-4318-8486-dbef129edfc0-1"
    // swiftlint:disable:next line_length
    private static let iframe = "<iframe class=\"lti-embed\" style=\"width: 720px; height: 405px; display: inline-block;\" title=\"bookmarks\" src=\"https://test.com/courses/123/external_tools/retrieve?display=borderless&amp;url=https%3A%2F%2Ftestmedia.com%2Flti%2Flaunch%3Fcustom_arc_launch_type%3Dbare_embed%26custom_arc_media_id%3D\(mediaID)%26custom_arc_start_at%3D0\" width=\"720\" height=\"405\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" allow=\"geolocation *; microphone *; camera *; midi *; encrypted-media *; autoplay *; clipboard-write *; display-capture *\" data-studio-resizable=\"true\" data-studio-tray-enabled=\"true\" data-studio-convertible-to-link=\"true\"></iframe>"

    func testExtractsMediaID() {
        let result = Self.iframe.extractStudioMediaIDFromIFrame()

        XCTAssertEqual(result, Self.mediaID)
    }

    func testExtractsMedia() {
        let testHTML = "<p>\(Self.iframe)</p>"

        let result = StudioHTMLParserInteractor.extractStudioLTIs(html: testHTML)

        XCTAssertEqual(
            result,
            [
                .init(
                    mediaLTILaunchID: Self.mediaID,
                    sourceFrame: Self.iframe
                ),
            ]
        )
    }
}
