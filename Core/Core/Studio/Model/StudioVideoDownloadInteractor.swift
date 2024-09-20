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

public struct StudioOfflineVideo: Equatable {
    public let ltiLaunchID: String
    public let videoLocation: URL
    /// The png file of the first frame of the video.
    public let videoPosterLocation: URL?
    public let videoMimeType: String
    public let captionLocations: [URL]
}

public protocol StudioVideoDownloadInteractor {

    func download(_ item: APIStudioMediaItem) -> AnyPublisher<StudioOfflineVideo, Error>
}

public class StudioVideoDownloadInteractorLive: StudioVideoDownloadInteractor {
    private let rootDirectory: URL
    private let captionsInteractor: StudioCaptionsInteractor
    private let videoCacheInteractor: StudioVideoCacheInteractor
    private let posterInteractor: StudioVideoPosterInteractor

    public init(
        rootDirectory: URL,
        captionsInteractor: StudioCaptionsInteractor,
        videoCacheInteractor: StudioVideoCacheInteractor,
        posterInteractor: StudioVideoPosterInteractor
    ) {
        self.rootDirectory = rootDirectory
        self.captionsInteractor = captionsInteractor
        self.videoCacheInteractor = videoCacheInteractor
        self.posterInteractor = posterInteractor
    }

    public func download(_ item: APIStudioMediaItem) -> AnyPublisher<StudioOfflineVideo, Error> {
        let mediaFolder = rootDirectory.appendingPathComponent(item.id.value, isDirectory: true)
        let videoFileLocation = mediaFolder
            .appendingPathComponent(item.id.value, isDirectory: false)
            .appendingPathExtension(item.url.pathExtension)

        return Just(())
            .setFailureType(to: Error.self)
            .map { [videoCacheInteractor] _ in
                videoCacheInteractor.isVideoDownloaded(videoLocation: videoFileLocation, expectedSize: item.size)
            }
            .flatMap { (isVideoCached: Bool) in
                if isVideoCached {
                    return Just(isVideoCached)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                return DownloadTaskPublisher(
                    parameters: .init(
                        remoteURL: item.url,
                        localURL: videoFileLocation
                    )
                )
                .collect() // Wait until progress percentage emits are finished.
                .mapToValue(isVideoCached)
                .eraseToAnyPublisher()
            }
            .flatMap { [captionsInteractor] isVideoCached in
                /// Captions are already downloaded with the media metadata so we write them to disk to make sure they are up-to-date
                captionsInteractor.write(
                    captions: item.captions,
                    to: mediaFolder
                )
                .map { (isVideoCached, $0) }
            }
            .map { [posterInteractor] (isVideoCached: Bool, captionURLs: [URL]) -> ([URL], URL?) in
                let posterLocation = posterInteractor.createVideoPosterIfNeeded(
                    isVideoCached: isVideoCached,
                    mediaFolder: mediaFolder,
                    videoFile: videoFileLocation
                )

                return (captionURLs, posterLocation)
            }
            .map { (captionURLs, posterURL) in
                StudioOfflineVideo(
                    ltiLaunchID: item.lti_launch_id,
                    videoLocation: videoFileLocation,
                    videoPosterLocation: posterURL,
                    videoMimeType: item.mime_type,
                    captionLocations: captionURLs
                )
            }
            .eraseToAnyPublisher()
    }
}
