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

public struct StudioLTIReplace {

    public static func replaceStudioIFrame(
        html: String,
        iFrame: String,
        video: URL,
        videoMimeType: String,
        captions: [URL]
    ) -> String {
        var captionTags = ""

        for caption in captions {
            let languageCode = caption.lastPathComponent.split(separator: ".").first

            guard let languageCode else {
                continue
            }

            captionTags.append("  <track kind=\"captions\" src=\"\(caption)\" srclang=\"\(languageCode)\"/>\n")
        }

        let videoTag = """
        <video>
          <source src="\(video)" type="\(videoMimeType)" />
        \(captionTags)</video>
        """

        let modifiedHtml = html.replacingOccurrences(of: iFrame, with: videoTag)
        return modifiedHtml
    }
}
