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
import CombineSchedulers

public protocol CourseSyncStudioMediaInteractor {
    func getContent(courseIDs: [String]) -> AnyPublisher<Void, Never>
}

public class CourseSyncStudioMediaInteractorLive: CourseSyncStudioMediaInteractor {
    private let offlineDirectory: URL
    private let studioAuthInteractor: StudioAPIAuthInteractor
    private let studioIFrameReplaceInteractor: StudioIFrameReplaceInteractor
    private let studioIFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor
    private let cleanupInteractor: StudioVideoCleanupInteractor
    private let downloadInteractor: StudioVideoDownloadInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public init(
        offlineDirectory: URL,
        authInteractor: StudioAPIAuthInteractor,
        iFrameReplaceInteractor: StudioIFrameReplaceInteractor,
        iFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor,
        cleanupInteractor: StudioVideoCleanupInteractor,
        downloadInteractor: StudioVideoDownloadInteractor,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.offlineDirectory = offlineDirectory
        self.studioAuthInteractor = authInteractor
        self.studioIFrameReplaceInteractor = iFrameReplaceInteractor
        self.studioIFrameDiscoveryInteractor = iFrameDiscoveryInteractor
        self.cleanupInteractor = cleanupInteractor
        self.downloadInteractor = downloadInteractor
        self.scheduler = scheduler
    }

    public func getContent(courseIDs: [String]) -> AnyPublisher<Void, Never> {
        Just(offlineDirectory)
            .setFailureType(to: Error.self)
            .receive(on: scheduler)
            .flatMap { [studioIFrameDiscoveryInteractor] offlineDirectory in
                studioIFrameDiscoveryInteractor.discoverStudioIFrames(in: offlineDirectory, courseIDs: courseIDs)
            }
            .flatMap { [studioAuthInteractor] (iframes: StudioIFramesByLocation) in
                studioAuthInteractor
                    .makeStudioAPI()
                    .mapError { $0 as Error }
                    .map { api in
                        (api, iframes)
                    }
            }
            .flatMap { api, iframes in
                Self.fetchStudioMediaItems(api: api, courseIDs: courseIDs)
                    .map { mediaItems in
                        var mediaLTIIDsToDownload = iframes.values.flatMap { $0 }.map { $0.mediaLTILaunchID }
                        mediaLTIIDsToDownload = Array(Set(mediaLTIIDsToDownload))
                        return (mediaItems, mediaLTIIDsToDownload, iframes)
                    }
            }
            .flatMap { [cleanupInteractor] (mediaItems, mediaLTIIDsToDownload, iframes) in
                return cleanupInteractor.removeNoLongerNeededVideos(
                    allMediaItemsOnAPI: mediaItems,
                    mediaLTIIDsUsedInOfflineMode: mediaLTIIDsToDownload
                )
                .map {
                    (mediaItems, mediaLTIIDsToDownload, iframes)
                }
            }
            .flatMap { [self, offlineDirectory] (mediaItems, mediaLTIIDsToDownload, iframes: StudioIFramesByLocation) in
                downloadStudioVideos(
                    offlineDirectory: offlineDirectory,
                    mediaItems: mediaItems,
                    mediaLTIIDsToDownload: mediaLTIIDsToDownload
                )
                .map { offlineVideos in
                    (offlineVideos, iframes)
                }
            }
            .tryMap { [studioIFrameReplaceInteractor] (offlineVideos: [StudioOfflineVideo], iframes: StudioIFramesByLocation) in
                for (htmlURL, iframes) in iframes {
                    try studioIFrameReplaceInteractor.replaceStudioIFrames(
                        inHtmlAtURL: htmlURL,
                        iframes: iframes,
                        offlineVideos: offlineVideos
                    )
                }
                return ()
            }
            .catch { (error: Error) -> Just<Void> in
                Logger.shared.error("Studio Offline Sync Failed: " + error.localizedDescription)
                Analytics.shared.logError(
                    name: "Studio Offline Sync Failed",
                    reason: error.localizedDescription
                )
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private static func fetchStudioMediaItems(
        api: API,
        courseIDs: [String]
    ) -> AnyPublisher<[APIStudioMediaItem], Error> {
        Publishers.Sequence(sequence: courseIDs)
            .flatMap { courseID in
                let request = GetStudioCourseMediaRequest(courseId: courseID)
                return api.makeRequest(request).map(\.body)
            }
            .collect()
            .map { (mediaData: [[APIStudioMediaItem]]) in
                mediaData.flatMap { $0 }
            }
            .eraseToAnyPublisher()
    }

    private func downloadStudioVideos(
        offlineDirectory: URL,
        mediaItems: [APIStudioMediaItem],
        mediaLTIIDsToDownload: [String]
    ) -> AnyPublisher<[StudioOfflineVideo], Error> {
        let mediaItemsForOffline = mediaItems.filter { mediaLTIIDsToDownload.contains($0.lti_launch_id) }

        return Publishers.Sequence(sequence: mediaItemsForOffline)
            .flatMap(maxPublishers: .max(1)) { [downloadInteractor] mediaItem in
                downloadInteractor.download(mediaItem)
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
