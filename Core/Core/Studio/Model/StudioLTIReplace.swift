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
    public enum ReplaceError: Error {
        case failedToOpenHtml
        case failedToConvertDataToString
        case offlineVideoIDNotFound
        case failedToConvertHtmlToData
        case failedToSaveUpdatedHtml
    }

    public static func replaceStudioIFrames(
        inHtmlAtURL htmlURL: URL,
        iframes: [StudioIFrame],
        offlineVideos: [StudioOfflineVideo]
    ) throws {
        guard let htmlData = try? Data(contentsOf: htmlURL) else {
            throw ReplaceError.failedToOpenHtml
        }

        guard var htmlString = String(data: htmlData, encoding: .utf8) else {
            throw ReplaceError.failedToConvertDataToString
        }

        for iframe in iframes {
            guard let offlineVideo = offlineVideos.first(where: { $0.ltiLaunchID == iframe.mediaLTILaunchID }) else {
                throw ReplaceError.offlineVideoIDNotFound
            }
            htmlString = StudioLTIReplace.replaceStudioIFrame(
                html: htmlString,
                iFrame: iframe.sourceHtml,
                video: offlineVideo.videoLocation,
                videoMimeType: offlineVideo.videoMimeType,
                captions: offlineVideo.captionLocations
            )
        }

        guard let updatedHtmlData = htmlString.data(using: .utf8) else {
            throw ReplaceError.failedToConvertHtmlToData
        }

        do {
            try updatedHtmlData.write(to: htmlURL)
        } catch (let error) {
            throw ReplaceError.failedToSaveUpdatedHtml
        }
    }

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

            captionTags.append("  <track kind=\"captions\" src=\"\(caption.path)\" srclang=\"\(languageCode)\"></track>\n")
        }

        let videoTag = """
        <video controls playsinline preload="auto">
          <source src="\(video.path)" type="\(videoMimeType)\" />
        \(captionTags)</video>
        """

        let modifiedHtml = html.replacingOccurrences(of: iFrame, with: videoTag)
        return modifiedHtml
    }
}
