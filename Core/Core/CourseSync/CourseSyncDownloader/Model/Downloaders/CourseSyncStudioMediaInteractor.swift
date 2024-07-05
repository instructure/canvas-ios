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
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let offlineDirectory: URL

    public init(
        offlineDirectory: URL,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.offlineDirectory = offlineDirectory
        self.scheduler = scheduler
    }

    public func getContent(courseIDs: [String]) -> AnyPublisher<Void, Never> {
        Just(offlineDirectory)
            .setFailureType(to: Error.self)
            .receive(on: scheduler)
            .flatMap { offlineDirectory in
                Self.discoverStudioIFrames(in: offlineDirectory, courseIDs: courseIDs)
            }
            .flatMap { (iframes: IFrames) in
                StudioAPIAuthInteractor
                    .makeStudioAPI()
                    .mapError { $0 as Error }
                    .map { api in
                        (api, iframes)
                    }
            }
            .flatMap { api, iframes in
                Self.downloadStudioMediaItems(api: api, courseIDs: courseIDs)
                    .map { mediaItems in
                        var mediaLTIIDsToDownload = iframes.values.flatMap { $0 }.map { $0.mediaLTILaunchID }
                        mediaLTIIDsToDownload = Array(Set(mediaLTIIDsToDownload))
                        return (mediaItems, mediaLTIIDsToDownload, iframes)
                    }
            }
            .flatMap { [offlineDirectory] (mediaItems, mediaLTIIDsToDownload, iframes: IFrames) in
                Self.downloadStudioVideos(
                    offlineDirectory: offlineDirectory,
                    mediaItems: mediaItems,
                    mediaLTIIDsToDownload: mediaLTIIDsToDownload
                )
                .map { offlineVideos in
                    (offlineVideos, iframes)
                }
            }
            .tryMap { (offlineVideos: [StudioOfflineVideo], iframes: IFrames) in
                for (htmlURL, iframes) in iframes {
                    try StudioLTIReplace.replaceStudioIFrames(
                        inHtmlAtURL: htmlURL,
                        iframes: iframes,
                        offlineVideos: offlineVideos
                    )
                }
                return ()
            }
            .catch { error in
                print("XXX \(error)")
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private typealias IFrames = [URL: [StudioIFrame]]

    private static func discoverStudioIFrames(
        in offlineDirectory: URL,
        courseIDs: [String]
    ) -> AnyPublisher<IFrames, Never> {
        Just(offlineDirectory)
            .map { offlineDirectory in
                let coursePaths = courseIDs.map { "course-\($0)"}
                return FileManager
                    .default
                    .allFiles(withExtension: "html", inDirectory: offlineDirectory)
                    .filter { url in
                        for coursePath in coursePaths where url.absoluteString.contains(coursePath) {
                            return true
                        }
                        return false
                    }
            }
            .flatMap { htmls in
                Publishers.Sequence(sequence: htmls)
            }
            .compactMap { htmlURL -> (URL, [StudioIFrame]) in
                let iframes = StudioHTMLParser.extractStudioIFrames(htmlLocation: htmlURL)
                return (htmlURL, iframes)
            }
            .collect()
            .map {
                var result: IFrames = [:]

                for (url, iframes) in $0 {
                    if iframes.isEmpty {
                        continue
                    }
                    result[url] = iframes
                }

                return result
            }
            .eraseToAnyPublisher()
    }

    private static func downloadStudioMediaItems(
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

    private static func downloadStudioVideos(
        offlineDirectory: URL,
        mediaItems: [APIStudioMediaItem],
        mediaLTIIDsToDownload: [String]
    ) -> AnyPublisher<[StudioOfflineVideo], Error> {
        let studioDirectory = offlineDirectory.appendingPathComponent("studio", isDirectory: true)
        let interactor = StudioMediaDownloadInteractor(rootDirectory: studioDirectory)
        let mediaItemsForOffline = mediaItems.filter { mediaLTIIDsToDownload.contains($0.lti_launch_id) }

        return Publishers.Sequence(sequence: mediaItemsForOffline)
            .flatMap(maxPublishers: .max(1)) { mediaItem in
                interactor.download(mediaItem)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    private static func extractUniqueMediaIDs(_ mediaByFile: [URL: [StudioIFrame]]) -> [String] {
        let mediaEntities = mediaByFile.values.flatMap { $0 }
        let mediaIDs = mediaEntities.map(\.mediaLTILaunchID)
        return Array(Set(mediaIDs))
    }
}
