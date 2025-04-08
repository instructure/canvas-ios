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
import Foundation

public protocol CourseSyncStudioMediaInteractor {
    func getContent(courseIDs: [CourseSyncID]) -> AnyPublisher<Void, Never>
}

public class CourseSyncStudioMediaInteractorLive: CourseSyncStudioMediaInteractor {
    private let studioAuthInteractor: StudioAPIAuthInteractor
    private let studioIFrameReplaceInteractor: StudioIFrameReplaceInteractor
    private let studioIFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor
    private let cleanupInteractor: StudioVideoCleanupInteractor
    private let metadataDownloadInteractor: StudioMetadataDownloadInteractor
    private let downloadInteractor: StudioVideoDownloadInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let envResolver: CourseSyncEnvironmentResolver

    public init(
        authInteractor: StudioAPIAuthInteractor,
        iFrameReplaceInteractor: StudioIFrameReplaceInteractor,
        iFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor,
        cleanupInteractor: StudioVideoCleanupInteractor,
        metadataDownloadInteractor: StudioMetadataDownloadInteractor,
        downloadInteractor: StudioVideoDownloadInteractor,
        scheduler: AnySchedulerOf<DispatchQueue>,
        envResolver: CourseSyncEnvironmentResolver
    ) {
        self.studioAuthInteractor = authInteractor
        self.studioIFrameReplaceInteractor = iFrameReplaceInteractor
        self.studioIFrameDiscoveryInteractor = iFrameDiscoveryInteractor
        self.cleanupInteractor = cleanupInteractor
        self.metadataDownloadInteractor = metadataDownloadInteractor
        self.downloadInteractor = downloadInteractor
        self.scheduler = scheduler
        self.envResolver = envResolver
    }

    public func getContent(courseIDs: [CourseSyncID]) -> AnyPublisher<Void, Never> {
        return Publishers
            .Sequence(sequence: courseIDs)
            .receive(on: scheduler)
            .flatMap({ [weak self] courseSyncID in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return getCourseContent(courseSyncID: courseSyncID)
            })
            .eraseToAnyPublisher()
    }

    private func getCourseContent(courseSyncID: CourseSyncID) -> AnyPublisher<Void, Never> {
        studioAuthInteractor
            .makeStudioAPI(env: envResolver.targetEnvironment(for: courseSyncID))
            .mapError({ $0 as Error })
            .flatMap({ [studioIFrameDiscoveryInteractor, metadataDownloadInteractor] api in

                return studioIFrameDiscoveryInteractor
                    .discoverStudioIFrames(courseID: courseSyncID)
                    .flatMap { [metadataDownloadInteractor] iframes in
                        metadataDownloadInteractor
                            .fetchStudioMediaItems(api: api, courseID: courseSyncID.value)
                            .map { mediaItems in
                                var mediaLTIIDsToDownload = iframes.values.flatMap { $0 }.map { $0.mediaLTILaunchID }
                                mediaLTIIDsToDownload = Array(Set(mediaLTIIDsToDownload))
                                return (mediaItems, mediaLTIIDsToDownload, iframes)
                            }
                    }
            })
            .flatMap { [envResolver, cleanupInteractor] (mediaItems, mediaLTIIDsToDownload, iframes) in
                let studioDirectory = envResolver.offlineStudioDirectory(for: courseSyncID)
                return cleanupInteractor.removeNoLongerNeededVideos(
                    allMediaItemsOnAPI: mediaItems,
                    mediaLTIIDsUsedInOfflineMode: mediaLTIIDsToDownload,
                    offlineStudioDirectory: studioDirectory
                )
                .map {
                    (mediaItems, mediaLTIIDsToDownload, iframes)
                }
            }
            .flatMap { [self] (mediaItems, mediaLTIIDsToDownload, iframes: StudioIFramesByLocation) in

                downloadStudioVideos(
                    mediaItems: mediaItems,
                    mediaLTIIDsToDownload: mediaLTIIDsToDownload,
                    rootDirectory: envResolver.offlineStudioDirectory(for: courseSyncID)
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
                Logger.shared.error("Studio Offline Sync Failed for Course \(courseSyncID.value): " + error.localizedDescription)
                RemoteLogger.shared.logError(
                    name: "Studio Offline Sync Failed for Course \(courseSyncID.value)",
                    reason: error.localizedDescription
                )
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private func downloadStudioVideos(
        mediaItems: [APIStudioMediaItem],
        mediaLTIIDsToDownload: [String],
        rootDirectory: URL
    ) -> AnyPublisher<[StudioOfflineVideo], Error> {
        let mediaItemsForOffline = mediaItems.filter { mediaLTIIDsToDownload.contains($0.lti_launch_id) }

        return Publishers.Sequence(sequence: mediaItemsForOffline)
            .flatMap(maxPublishers: .max(1)) { [downloadInteractor] mediaItem in
                downloadInteractor.download(mediaItem, rootDirectory: rootDirectory)
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
