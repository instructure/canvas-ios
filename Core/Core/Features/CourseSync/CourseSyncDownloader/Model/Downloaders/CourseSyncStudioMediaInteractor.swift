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
    private struct CourseMediaData {
        let studioDirectory: URL
        var mediaItems: [APIStudioMediaItem] = []
        var iframes: StudioIFramesByLocation = [:]
        var idsToDownload: [String] {
            iframes
                .values
                .flatMap { $0 }
                .map { $0.mediaLTILaunchID }
        }
    }

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
            .flatMap { [weak self] courseSyncID -> AnyPublisher<CourseMediaData, Error> in
                guard let self else {
                    return Publishers.noInstanceFailure(output: CourseMediaData.self)
                }
                return getCourseMedia(courseSyncID: courseSyncID)
            }
            .collect()
            .flatMap { (allCoursesMedia: [CourseMediaData]) -> AnyPublisher<CourseMediaData, Never> in
                let mediaListByStudioDirectory: [URL: [CourseMediaData]] = Dictionary(
                    grouping: allCoursesMedia,
                    by: { $0.studioDirectory }
                )
                return Publishers.Sequence(sequence: mediaListByStudioDirectory)
                    .map { (studioDirectory, mediaList) in
                        var group = CourseMediaData(studioDirectory: studioDirectory)
                        mediaList.forEach { courseMedia in
                            group.iframes.merge(courseMedia.iframes) { $0 + $1 }
                            group.mediaItems.append(contentsOf: courseMedia.mediaItems)
                        }
                        return group
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { [cleanupInteractor] mediaData in
                return cleanupInteractor
                    .removeNoLongerNeededVideos(
                        allMediaItemsOnAPI: mediaData.mediaItems,
                        mediaLTIIDsUsedInOfflineMode: mediaData.idsToDownload,
                        offlineStudioDirectory: mediaData.studioDirectory
                    )
                    .map { mediaData }
            }
            .flatMap { [weak self] mediaData in
                guard let self else { return Publishers.noInstanceFailure(output: Void.self) }
                return self.downloadMediaTweakingIFrameReferences(mediaData)
            }
            .catch { error -> AnyPublisher<Void, Never> in
                Logger.shared.error("Studio Offline Sync Failed: " + error.debugDescription)
                RemoteLogger.shared.logError(
                    name: "Studio Offline Sync Failed",
                    reason: error.debugDescription
                )
                return Just(()).eraseToAnyPublisher()
            }
            .collect()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func getCourseMedia(courseSyncID: CourseSyncID) -> AnyPublisher<CourseMediaData, Error> {
        let studioDirectory = envResolver
            .offlineStudioDirectory(for: courseSyncID)

        let studioApiPublisher = studioAuthInteractor
            .makeStudioAPI(env: envResolver.targetEnvironment(for: courseSyncID), courseId: courseSyncID.value)
            .mapError { $0 as Error }

        let iframesDiscoveryPublisher = studioIFrameDiscoveryInteractor
            .discoverStudioIFrames(courseID: courseSyncID)
            .setFailureType(to: Error.self)

        return Publishers
            .CombineLatest(studioApiPublisher, iframesDiscoveryPublisher)
            .flatMap { [metadataDownloadInteractor] (api, iframes) in

                return metadataDownloadInteractor
                    .fetchStudioMediaItems(api: api, courseID: courseSyncID.localID)
                    .map { mediaItems in
                        return CourseMediaData(
                            studioDirectory: studioDirectory,
                            mediaItems: mediaItems,
                            iframes: iframes
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    private func downloadMediaTweakingIFrameReferences(_ mediaData: CourseMediaData) -> AnyPublisher<Void, Error> {
        let studioDirectory = mediaData.studioDirectory
        let idsToDownload = mediaData.idsToDownload
        let mediaItemsForOffline = mediaData
            .mediaItems
            .filter { idsToDownload.contains($0.lti_launch_id) }

        return Publishers.Sequence(sequence: mediaItemsForOffline)
            .flatMap(maxPublishers: .max(1)) { [downloadInteractor] mediaItem in
                downloadInteractor.download(mediaItem, rootDirectory: studioDirectory)
            }
            .collect()
            .tryMap { [studioIFrameReplaceInteractor] offlineVideos in

                for (htmlURL, iframes) in mediaData.iframes {
                    try studioIFrameReplaceInteractor.replaceStudioIFrames(
                        inHtmlAtURL: htmlURL,
                        iframes: iframes,
                        offlineVideos: offlineVideos
                    )
                }
                return ()
            }
            .eraseToAnyPublisher()
    }
}
