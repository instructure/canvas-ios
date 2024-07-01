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

public struct StudioLTIParser {
    public struct Media: Equatable {
        let mediaLTILaunchID: String
        let sourceFrame: String
    }

    public static func extractStudioLTIs(html: String) -> [Media] {
        let iframes = html.extractiFrames()
        return iframes.compactMap { iframe in
            guard let mediaID = iframe.extractStudioMediaIDFromIFrame() else {
                return nil
            }
            return Media(
                mediaLTILaunchID: mediaID,
                sourceFrame: iframe
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
