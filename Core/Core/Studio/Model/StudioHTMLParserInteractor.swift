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

import Foundation

public struct StudioIFrame {
    /// The studio media ID the iframe pointing to. We use this to get the media's real ID from the API.
    let mediaLTILaunchID: String
    /// The html of the frame, we use this to replace the iframe with a video tag pointing to the downloded media.
    let sourceHtml: String
}

public class StudioHTMLParserInteractor {

    public func extractStudioIFrames(htmlLocation: URL) -> [StudioIFrame] {
        guard let htmlData = try? Data(contentsOf: htmlLocation),
              let htmlString = String(data: htmlData, encoding: .utf8)
        else {
            return []
        }

        let iframes = htmlString.extractiFrames()

        return iframes.compactMap { iframe in
            guard let mediaID = iframe.extractStudioMediaIDFromIFrame() else {
                return nil
            }
            return StudioIFrame(
                mediaLTILaunchID: mediaID,
                sourceHtml: iframe
            )
        }
    }
}

extension String {

    // custom_arc_media_id%3D([^%\"]+)
    // swiftlint:disable:next force_try
    private static let mediaIDPattern = try! NSRegularExpression(
        pattern: "custom_arc_media_id%3D([^%\\\"]+)"
    )

    func extractStudioMediaIDFromIFrame() -> String? {
        Self.mediaIDPattern
            .matches(in: self, range: nsRange)
            .compactMap { result in
                guard result.numberOfRanges > 1,
                      let range = Range(result.range(at: 1), in: self)
                else {
                    return nil
                }

                return String(self[range])
            }
            .first
    }
}
