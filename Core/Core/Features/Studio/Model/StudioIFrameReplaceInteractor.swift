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

public enum StudioIFrameReplaceError: LocalizedError {
    case failedToOpenHtml(Error)
    case failedToConvertDataToString
    case offlineVideoIDNotFound
    case failedToConvertHtmlToData
    case failedToSaveUpdatedHtml

    public var errorDescription: String? {
        // StudioIFrameReplaceError.failedToConvertDataToString
        "\(Self.self).\(self)"
    }
}

public protocol StudioIFrameReplaceInteractor {

    func replaceStudioIFrames(
        inHtmlAtURL htmlURL: URL,
        iframes: [StudioIFrame],
        offlineVideos: [StudioOfflineVideo]
    ) throws
}

public class StudioIFrameReplaceInteractorLive: StudioIFrameReplaceInteractor {

    public func replaceStudioIFrames(
        inHtmlAtURL htmlURL: URL,
        iframes: [StudioIFrame],
        offlineVideos: [StudioOfflineVideo]
    ) throws {
        let htmlData: Data
        do {
            htmlData = try Data(contentsOf: htmlURL)
        } catch (let error) {
            throw StudioIFrameReplaceError.failedToOpenHtml(error)
        }

        guard var htmlString = String(data: htmlData, encoding: .utf8) else {
            throw StudioIFrameReplaceError.failedToConvertDataToString
        }

        for iframe in iframes {
            guard let offlineVideo = offlineVideos.first(where: { $0.ltiLaunchID == iframe.mediaLTILaunchID }) else {
                throw StudioIFrameReplaceError.offlineVideoIDNotFound
            }
            htmlString = replaceStudioIFrame(
                html: htmlString,
                iFrameHtml: iframe.sourceHtml,
                studioVideo: offlineVideo
            )
        }

        guard let updatedHtmlData = htmlString.data(using: .utf8) else {
            throw StudioIFrameReplaceError.failedToConvertHtmlToData
        }

        do {
            try updatedHtmlData.write(to: htmlURL)
        } catch {
            throw StudioIFrameReplaceError.failedToSaveUpdatedHtml
        }
    }

    public func replaceStudioIFrame(
        html: String,
        iFrameHtml: String,
        studioVideo: StudioOfflineVideo
    ) -> String {
        var captionTags = ""

        for caption in studioVideo.captions {
            captionTags.append("  <track kind=\"captions\" src=\"\(caption.relativePath)\" srclang=\"\(caption.languageCode)\" />\n")
        }

        let posterProperty: String = {
            guard let posterLocation = studioVideo.videoPosterRelativePath else {
                return ""
            }
            return " poster=\"\(posterLocation)\""
        }()

        let videoTag = """
        <video controls playsinline preload="auto"\(posterProperty)>
          <source src="\(studioVideo.videoRelativePath)" type="\(studioVideo.videoMimeType)\" />
        \(captionTags)</video>
        """

        let modifiedHtml = html.replacingOccurrences(of: iFrameHtml, with: videoTag)
        return modifiedHtml
    }
}
