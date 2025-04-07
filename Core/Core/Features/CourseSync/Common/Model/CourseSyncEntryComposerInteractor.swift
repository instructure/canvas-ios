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
    private let filesInteractor: CourseSyncFilesInteractor

    init(filesInteractor: CourseSyncFilesInteractor = CourseSyncFilesInteractorLive()) {
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

        var mappedTabs = tabs.map {
            CourseSyncEntry.Tab(
                id: "courses/\(course.courseId)/tabs/\($0.id)",
                name: $0.label,
                type: $0.name
            )
        }
        mappedTabs.append(
            CourseSyncEntry.Tab(
                id: "courses/\(course.courseId)/tabs/additional-content",
                name: String(localized: "Additional Content", bundle: .core),
                type: .additionalContent,
                selectionState: .deselected
            )
        )

        return filesInteractor
            .getFiles(
                courseId: course.courseId.localID,
                useCache: useCache,
                environment: .resolved(for: apiBaseURL)
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
            .map { files in
                CourseSyncEntry(
                    name: course.name,
                    id: "courses/\(course.courseId)",
                    hasFrontPage: course.hasFrontPage,
                    tabs: mappedTabs,
                    apiBaseURL: apiBaseURL,
                    files: files
                )
            }
            .eraseToAnyPublisher()
    }
}
