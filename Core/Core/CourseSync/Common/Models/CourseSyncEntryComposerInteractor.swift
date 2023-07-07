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
    public func composeEntry(
        from course: CourseSyncSelectorCourse,
        useCache: Bool
    ) -> AnyPublisher<CourseSyncEntry, Error> {
        let tabs = Array(course.tabs).offlineSupportedTabs()
        let mappedTabs = tabs.map {
            CourseSyncEntry.Tab(
                id: "courses/\(course.courseId)/tabs/\($0.id)",
                name: $0.label,
                type: $0.name
            )
        }
        if tabs.isFilesTabEnabled() {
            return getFoldersAndFiles(courseId: course.courseId, useCache: useCache)
                .map { files in
                    CourseSyncEntry(
                        name: course.name,
                        id: "courses/\(course.courseId)",
                        tabs: mappedTabs,
                        files: files
                    )
                }
                .eraseToAnyPublisher()
        } else {
            return Just(
                CourseSyncEntry(
                    name: course.name,
                    id: "courses/\(course.courseId)",
                    tabs: mappedTabs,
                    files: []
                )
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }

    /// Recursively looks up every file and folder under the specified `courseId` and returns a list of `CourseSyncEntry.File`.
    private func getFoldersAndFiles(
        courseId: String,
        useCache: Bool
    ) -> AnyPublisher<[CourseSyncEntry.File], Error> {
        unowned let unownedSelf = self

        let store = ReactiveStore(
            useCase: GetFolderByPath(
                context: .course(courseId)
            )
        )
        let publisher = useCache ? store.getEntitiesFromDatabase() : store.getEntities()

        return publisher
            .flatMap {
                Publishers.Sequence(sequence: $0)
                    .filter { !$0.lockedForUser && !$0.hiddenForUser }
                    .setFailureType(to: Error.self)
                    .flatMap { unownedSelf.getFiles(folderID: $0.id, initialArray: [], useCache: useCache) }
            }
            .map {
                $0
                    .compactMap { $0.file }
                    .filter { $0.url != nil && $0.mimeClass != nil }
                    .map {
                        CourseSyncEntry.File(
                            id: "courses/\(courseId)/files/\($0.id ?? Foundation.UUID().uuidString)",
                            displayName: $0.displayName ?? NSLocalizedString("Unknown file", comment: ""),
                            fileName: $0.filename,
                            url: $0.url!,
                            mimeClass: $0.mimeClass!,
                            bytesToDownload: $0.size
                        )
                    }
            }
            .replaceEmpty(with: [])
            .eraseToAnyPublisher()
    }

    private func getFiles(
        folderID: String,
        initialArray: [FolderItem],
        useCache: Bool
    ) -> AnyPublisher<[FolderItem], Error> {
        unowned let unownedSelf = self

        var result = initialArray

        return getFolderItems(folderID: folderID, useCache: useCache)
            .flatMap { files, folderIDs in
                result.append(contentsOf: files)

                guard folderIDs.count > 0 else {
                    return Just([result])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Publishers.Sequence(sequence: folderIDs)
                    .setFailureType(to: Error.self)
                    .flatMap {
                        unownedSelf.getFiles(
                            folderID: $0,
                            initialArray: result,
                            useCache: useCache
                        )
                        .handleEvents(receiveOutput: { result = $0 })
                    }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .first()
            .map { _ in result }
            .eraseToAnyPublisher()
    }

    private func getFolderItems(folderID: String, useCache: Bool) -> AnyPublisher<([FolderItem], [String]), Error> {
        let store = ReactiveStore(
            useCase: GetFolderItems(
                folderID: folderID
            )
        )
        let publisher = useCache ? store.getEntitiesFromDatabase() : store.getEntities()

        return publisher
        .tryCatch { error -> AnyPublisher<[FolderItem], Error> in
            if case .unauthorized = error as? Core.APIError {
                return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                throw error
            }
        }
        .map {
            let files = $0
                .filter {
                    if let file = $0.file {
                        return !file.lockedForUser && !file.hiddenForUser
                    } else {
                        return false
                    }
                }
            let folderIDs = $0
                .filter { $0.folder != nil }
                .compactMap { $0.folder }
                .filter { !$0.lockedForUser && !$0.hiddenForUser }
                .map { $0.id }

            return (files, folderIDs)
        }
        .eraseToAnyPublisher()
    }
}
