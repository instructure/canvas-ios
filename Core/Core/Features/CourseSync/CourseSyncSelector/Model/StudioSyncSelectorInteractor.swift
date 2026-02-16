//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

protocol StudioSyncSelectorInteractor: AnyObject {
    func getMediaItems(_ courseSyncID: CourseSyncID) -> AnyPublisher<[FetchedStudioMediaItem], Error>
}

final class StudioSyncSelectorInteractorLive: StudioSyncSelectorInteractor {

    let studioAuthInteractor: StudioAPIAuthInteractor
    let studioIFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor
    let metadataDownloadInteractor: StudioMetadataDownloadInteractor
    let envResolver: CourseSyncEnvironmentResolver = CourseSyncEnvironmentResolverLive()

    init(
        authInteractor: StudioAPIAuthInteractor,
        metadataDownloadInteractor: StudioMetadataDownloadInteractor,
    ) {
        self.studioAuthInteractor = authInteractor
        self.studioIFrameDiscoveryInteractor = StudioIFrameDiscoveryInteractorLive(
            studioHtmlParser: StudioHTMLParserInteractorLive(),
            envResolver: envResolver
        )
        self.metadataDownloadInteractor = metadataDownloadInteractor
    }

    func getMediaItems(_ courseSyncID: CourseSyncID) -> AnyPublisher<[FetchedStudioMediaItem], any Error> {

        let env = envResolver.targetEnvironment(for: courseSyncID)

        let studioDirectory = envResolver
            .offlineStudioDirectory(for: courseSyncID)

        let studioApiPublisher = studioAuthInteractor
            .makeStudioAPI(env: env, courseId: courseSyncID.value)
            .mapError { $0 as Error }

        let iframesDiscoveryPublisher = studioIFrameDiscoveryInteractor
            .discoverStudioIFrames(courseID: courseSyncID)
            .setFailureType(to: Error.self)

        return Publishers
            .CombineLatest(studioApiPublisher, iframesDiscoveryPublisher)
            .flatMap { [metadataDownloadInteractor] (api, iframes) in
                let itemsToDownload = iframes
                    .values
                    .flatMap { $0 }
                    .map { $0.mediaLTILaunchID }

                return metadataDownloadInteractor
                    .fetchStudioMediaItems(api: api, courseID: courseSyncID.localID)
                    .map { items in
                        items.filter { item in
                            itemsToDownload.contains(item.lti_launch_id)
                        }
                    }

            }
            .flatMap { items in
                items
                    .publisher
                    .flatMap { item in
                        env
                            .api
                            .makeRequest(item.url, method: .head)
                            .map { response -> FetchedStudioMediaItem in
                                if let headers = (response as? HTTPURLResponse)?.allHeaderFields {
                                    let contentLength = headers.first(where: { ($0.key as? String)?.lowercased() == "content-length" })?.value as? String
                                    if let lengthValue = contentLength, let size = Int64(lengthValue) {
                                        return FetchedStudioMediaItem(
                                            source: item,
                                            downloadSize: size
                                        )
                                    }
                                }
                                return FetchedStudioMediaItem(source: item, downloadSize: -1)
                            }
                    }
                .collect()
            }
            .eraseToAnyPublisher()
    }
}

struct FetchedStudioMediaItem {
    let source: APIStudioMediaItem
    let downloadSize: Int64
}
