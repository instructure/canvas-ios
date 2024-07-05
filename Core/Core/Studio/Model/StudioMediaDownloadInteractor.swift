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

import Combine

public struct StudioOfflineVideo {
    public let ltiLaunchID: String
    public let videoLocation: URL
    public let videoMimeType: String
    public let captionLocations: [URL]
}

public class StudioMediaDownloadInteractor {
    private let rootDirectory: URL

    public init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
    }

    public func download(_ item: APIStudioMediaItem) -> AnyPublisher<StudioOfflineVideo, Error> {
        let mediaFolder = rootDirectory.appendingPathComponent(item.id.value, isDirectory: true)
        let mediaFile = mediaFolder
            .appendingPathComponent(item.id.value, isDirectory: false)
            .appendingPathExtension(item.url.pathExtension)

        return Just(())
            .setFailureType(to: Error.self)
            .flatMap { _ in
                DownloadTaskPublisher(parameters: .init(remoteURL: item.url, localURL: mediaFile))
                    .collect()
                    .mapToVoid()
            }
            .flatMap {
                item.captions.save(to: mediaFolder)
            }
            .map { captionURLs in
                StudioOfflineVideo(
                    ltiLaunchID: item.lti_launch_id,
                    videoLocation: mediaFile,
                    videoMimeType: item.mime_type,
                    captionLocations: captionURLs
                )
            }
            .eraseToAnyPublisher()
    }
}
