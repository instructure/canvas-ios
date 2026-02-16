//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Foundation

public protocol CourseSyncEntryComposerInteractor {
    /// Downloads all the available files for a course, and transforms `CourseSyncSelectorCourse` to `CourseSyncEntry`.
    func composeEntry(
        from course: CourseSyncSelectorCourse,
        useCache: Bool
    ) -> AnyPublisher<CourseSyncEntry, Error>
}

public final class CourseSyncEntryComposerInteractorLive: CourseSyncEntryComposerInteractor {
    private let studioInteractor: StudioSyncSelectorInteractor
    private let filesInteractor: CourseSyncFilesInteractor

    init(
        filesInteractor: CourseSyncFilesInteractor = CourseSyncFilesInteractorLive()
    ) {
        self.studioInteractor = StudioSyncSelectorInteractorLive(
            authInteractor: StudioAPIAuthInteractorLive(),
            metadataDownloadInteractor: StudioMetadataDownloadInteractorLive()
        )
        self.filesInteractor = filesInteractor
    }

    public func composeEntry(
        from course: CourseSyncSelectorCourse,
        useCache: Bool
    ) -> AnyPublisher<CourseSyncEntry, Error> {
        let tabs = Array(course.tabs).offlineSupportedTabs()
        let apiBaseURL = course
            .tabs
            .compactMap({ $0.apiBaseURL })
            .first(where: { $0 != AppEnvironment.shared.api.baseURL })

        var mappedTabs = tabs
            .compactMap { tab -> CourseSyncEntry.Tab? in
                guard let type = SyncTab(name: tab.name) else { return nil }
                return CourseSyncEntry.Tab(
                    id: "courses/\(course.courseId)/tabs/\(tab.id)",
                    name: tab.label,
                    type: type
                )
            }

        mappedTabs.append(
            CourseSyncEntry.Tab(
                id: "courses/\(course.courseId)/tabs/studio",
                name: String(localized: "Studio", bundle: .core),
                type: .studio,
                selectionState: .deselected
            )
        )

        mappedTabs.append(
            CourseSyncEntry.Tab(
                id: "courses/\(course.courseId)/tabs/additional-content",
                name: String(localized: "Additional Content", bundle: .core),
                type: .additionalContent,
                selectionState: .deselected
            )
        )

        let courseSyncID = CourseSyncID(value: course.courseId, apiBaseURL: apiBaseURL)

        let filesEntries = filesInteractor
            .getFiles(
                courseId: course.courseId.localID,
                useCache: useCache,
                environment: .resolved(for: apiBaseURL, contextShardID: course.courseId.shardID)
            )
            .map { files in
                files.map {
                    CourseSyncEntry.File(
                        id: "courses/\(course.courseId)/files/\($0.id ?? Foundation.UUID().uuidString)",
                        displayName: $0.displayName ?? String(localized: "Unknown file", bundle: .core),
                        fileName: $0.filename,
                        url: $0.url!,
                        mimeClass: $0.mimeClass!,
                        updatedAt: $0.updatedAt,
                        bytesToDownload: $0.size
                    )
                }
            }

        let studioEntries = studioInteractor
            .getMediaItems(courseSyncID)
            .map { items in
                items.map { item in
                    CourseSyncEntry.StudioMediaItem(
                        id: "courses/\(course.courseId)/studio/\(item.source.id)",
                        lti_launch_id: item.source.lti_launch_id,
                        title: item.source.title,
                        mimeType: item.source.mime_type,
                        bytesToDownload: Int(item.downloadSize),
                        url: item.source.url
                    )
                }
            }
            .eraseToAnyPublisher()

        return Publishers
            .CombineLatest(filesEntries, studioEntries)
            .map { (files, items) in

                CourseSyncEntry(
                    name: course.name,
                    id: "courses/\(course.courseId)",
                    hasFrontPage: course.hasFrontPage,
                    tabs: mappedTabs,
                    apiBaseURL: apiBaseURL,
                    files: files,
                    studioMedia: items
                )
            }
            .eraseToAnyPublisher()
    }
}
