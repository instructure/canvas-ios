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
    func studioApi(courseSyncID: CourseSyncID) -> AnyPublisher<API, Error>
    func downloadContent(mediaItem: CourseSyncEntry.StudioMediaItem, courseSyncID: CourseSyncID, api: API) -> AnyPublisher<Float, Error>
    func removeUnavailableStudioMediaItems(
        courseSyncID: CourseSyncID,
        newMediaIDs: [String]
    ) -> AnyPublisher<Void, Error>
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
        let groupMediaByStudioDirectory: ([CourseMediaData]) -> AnyPublisher<CourseMediaData, Never> = { allCoursesMedia in
            let mediaListByStudioDirectory: [URL: [CourseMediaData]] = Dictionary(
                grouping: allCoursesMedia,
                by: { $0.studioDirectory }
            )
            return Publishers.Sequence(sequence: mediaListByStudioDirectory)
                .map { (studioDirectory, mediaList) -> CourseMediaData in
                    var group = CourseMediaData(studioDirectory: studioDirectory)
                    mediaList.forEach { courseMedia in
                        group.iframes.merge(courseMedia.iframes) { $0 + $1 }
                        group.mediaItems.append(contentsOf: courseMedia.mediaItems)
                    }
                    return group
                }
                .eraseToAnyPublisher()
        }

        let removeNoLongerNeededVideos: (CourseMediaData) -> AnyPublisher<CourseMediaData, Error> = { [cleanupInteractor] mediaData in
            cleanupInteractor
                .removeNoLongerNeededVideos(
                    allMediaItemsOnAPI: mediaData.mediaItems,
                    mediaLTIIDsUsedInOfflineMode: mediaData.idsToDownload,
                    offlineStudioDirectory: mediaData.studioDirectory
                )
                .map { mediaData }
                .eraseToAnyPublisher()
        }

        let collectCourseMedia = Publishers
            .Sequence(sequence: courseIDs)
            .receive(on: scheduler)
            .flatMap { [weak self] courseSyncID -> AnyPublisher<CourseMediaData, Error> in
                guard let self else {
                    return Publishers.noInstanceFailure(output: CourseMediaData.self)
                }
                return getCourseMedia(courseSyncID: courseSyncID)
            }
            .collect()

        return collectCourseMedia
            .flatMap(groupMediaByStudioDirectory)
            .flatMap(removeNoLongerNeededVideos)
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

    private func tweakingIFrameReferences(_ mediaData: CourseMediaData, expectedSize: Int) -> AnyPublisher<Void, Error> {

        guard let mediaItem = mediaData.mediaItems.first else {
            return Publishers.noInstanceFailure()
        }

        let studioDirectory = mediaData.studioDirectory

        return Just(mediaItem)
            .flatMap { [downloadInteractor] item in
                downloadInteractor
                    .downloadCaptionsPoster(
                        item,
                        expectedSize: expectedSize,
                        rootDirectory: studioDirectory
                    )
            }
            .tryMap { [studioIFrameReplaceInteractor] offlineVideo in
                for (htmlURL, iframes) in mediaData.iframes {
                    try studioIFrameReplaceInteractor.replaceStudioIFrames(
                        inHtmlAtURL: htmlURL,
                        iframes: iframes,
                        offlineVideos: [offlineVideo]
                    )
                }
                return ()
            }
            .eraseToAnyPublisher()
    }

    public func studioApi(courseSyncID: CourseSyncID) -> AnyPublisher<API, Error> {
        return studioAuthInteractor
            .makeStudioAPI(env: envResolver.targetEnvironment(for: courseSyncID), courseId: courseSyncID.value)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    public func downloadContent(mediaItem: CourseSyncEntry.StudioMediaItem, courseSyncID: CourseSyncID, api: API) -> AnyPublisher<Float, Error> {

        let studioDirectory = envResolver
            .offlineStudioDirectory(for: courseSyncID)

        let iframesDiscoveryPublisher = studioIFrameDiscoveryInteractor
            .discoverStudioIFrames(courseID: courseSyncID)
            .setFailureType(to: Error.self)

        return iframesDiscoveryPublisher
            .flatMap { [metadataDownloadInteractor, downloadInteractor] iframes in

                return metadataDownloadInteractor
                    .fetchStudioMediaItem(api: api, mediaID: mediaItem.id, courseID: courseSyncID.localID)
                    .flatMap { [weak self] item in
                        guard let self else {
                            return Publishers.noInstanceFailure(output: APIStudioMediaItem.self)
                        }

                        return self.tweakingIFrameReferences(
                            CourseMediaData(
                                studioDirectory: studioDirectory,
                                mediaItems: [item],
                                iframes: iframes
                            ),
                            expectedSize: mediaItem.bytesToDownload
                        )
                        .map { item }
                        .eraseToAnyPublisher()
                    }
                    .flatMap { fetchedItem in
                        return downloadInteractor
                            .download(fetchedItem, expectedSize: mediaItem.bytesToDownload, rootDirectory: studioDirectory)
                    }
            }
            .eraseToAnyPublisher()
    }

    public func removeUnavailableStudioMediaItems(
        courseSyncID: CourseSyncID,
        newMediaIDs: [String]
    ) -> AnyPublisher<Void, Error> {
        guard let sessionID = envResolver.loginSession(for: courseSyncID)?.uniqueID else {
            return Fail(error:
                NSError.instructureError(
                    String(localized: "There was an unexpected error. Please try again.", bundle: .core)
                )
            )
            .eraseToAnyPublisher()
        }

        let fileManager = FileManager.default
        let studioDirectory = envResolver
            .offlineStudioDirectory(for: courseSyncID)

        let studioMediaIDsArr: [String] = (try? fileManager.contentsOfDirectory(atPath: studioDirectory.path)) ?? []
        let studioMediaIDs = Set(studioMediaIDsArr)
        let mappedNewMediaIDs = newMediaIDs

        let unavailableFileFolderURLs = studioMediaIDs
            .subtracting(Set(mappedNewMediaIDs))
            .map { studioDirectory.appendingPathComponent($0) }

        unowned let unownedSelf = self

        return unavailableFileFolderURLs
            .publisher
            .tryMap { try fileManager.removeItem(at: $0) }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
