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

public struct StudioOfflineVideo: Equatable {
    public let ltiLaunchID: String
    public let videoRelativePath: String
    /// The png file of the first frame of the video.
    public let videoPosterRelativePath: String?
    public let videoMimeType: String
    public let captions: [Caption]

    /// - parameters:
    ///   - baseURL: This URL will be used to create relative paths to the video files. This url should also be used as a`baseURL` in `WKWebView` when presenting a html string with such relative paths .
    public init(
        ltiLaunchID: String,
        videoLocation: URL,
        videoPosterLocation: URL?,
        videoMimeType: String,
        captionLocations: [URL],
        baseURL: URL = URL.Directories.documents
    ) throws {
        self.ltiLaunchID = ltiLaunchID
        self.videoMimeType = videoMimeType
        captions = try captionLocations.map {
            try Caption(captionUrl: $0, baseUrl: baseURL)
        }

        videoRelativePath = try videoLocation.makeRelativePath(toBaseUrl: baseURL)
        videoPosterRelativePath = try videoPosterLocation?.makeRelativePath(toBaseUrl: baseURL)
    }
}

extension StudioOfflineVideo {
    public struct Caption: Equatable {
        public let relativePath: String
        public let languageCode: String

        public init(
            captionUrl: URL,
            baseUrl: URL
        ) throws {
            let languageCode = captionUrl.lastPathComponent.split(separator: ".").first

            guard let languageCode else {
                throw NSError.instructureError("No language code detected in file name.")
            }

            relativePath = try captionUrl.makeRelativePath(toBaseUrl: baseUrl)
            self.languageCode = String(languageCode)
        }
    }
}
