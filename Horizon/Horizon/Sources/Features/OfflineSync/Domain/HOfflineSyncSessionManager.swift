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

import Core
import Combine
import Foundation

protocol HOfflineSyncSessionManager {
    var sessionID: String { get }
    var syncedItemPaths: [String] { get }
    func clearSessionData()
    func finalizeSync(courses: [OfflineCourseItem])
    func saveCompletedSync(courses: [OfflineCourseItem], files: [OfflineFileItem])
    func deleteCourseFolder(courseIds: [String], sessionID: String) 
}

final class HOfflineSyncSessionManagerLive: HOfflineSyncSessionManager {
    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public variables

    var sessionID: String { session.sessionID }
    var syncedItemPaths: [String] { session.horizonOfflineSyncItems }

    // MARK: - Dependencies

    private var session: SessionDefaults
    private let filesInteractor: HCourseSyncFilesInteractor
    private let pagesInteractor: HCourseSyncPagesInteractor
    private let fileManager: FileManager

    // MARK: - Init

    init(
        session: SessionDefaults,
        filesInteractor: HCourseSyncFilesInteractor,
        pagesInteractor: HCourseSyncPagesInteractor,
        fileManager: FileManager = .default
    ) {
        self.session = session
        self.filesInteractor = filesInteractor
        self.pagesInteractor = pagesInteractor
        self.fileManager = fileManager
    }

    func clearSessionData() {
        session.horizonOfflineSyncItems = []
        session.horizonOfflineSyncFileMetadata = [:]
    }

    func finalizeSync(courses: [OfflineCourseItem]) {
        removeDeselectedCourseFolders(courses: courses)
        updateFileMetadata(courses: courses)
        removeUnavailableFiles(courses: courses)
        session.horizonOfflineSyncItems = []
    }

    func saveCompletedSync(courses: [OfflineCourseItem], files: [OfflineFileItem]) {
        let coursePaths = courses.map { OfflineType.course(id: $0.id).path() }
        let filePaths = files
            .filter { $0.downloadState == .downloaded }
            .map { OfflineType.file(courseID: $0.courseID, fileID: $0.id).path() }
        appendSyncItems(coursePaths + filePaths)
    }

    func deleteCourseFolder(courseIds: [String], sessionID: String) {
        courseIds.forEach { courseId in
            let folderURL = URL.Directories.documents.appendingPathComponent(
            "\(sessionID)/Offline/course-\(courseId)"
            )
            try? fileManager.removeItem(at: folderURL)
        }
    }

    // MARK: - Private

    private func appendSyncItems(_ newItems: [String]) {
        session.horizonOfflineSyncItems.append(contentsOf: newItems)
    }

    private func removeDeselectedCourseFolders(courses: [OfflineCourseItem]) {
        let sessionID = session.sessionID
        let newCourseIDs = Set(courses.map(\.id))
        let deselectedCourseIDs = session.horizonOfflineSyncItems
            .compactMap { OfflineType.parse(path: $0) }
            .compactMap { if case .course(let id) = $0 { return id } else { return nil } }
            .filter { !newCourseIDs.contains($0) }

        deselectedCourseIDs.forEach { courseID in
            let folderURL = URL.Directories.documents.appendingPathComponent(
                URL.Paths.Offline.courseFolder(sessionID: sessionID, courseId: courseID)
            )
            try? FileManager.default.removeItem(at: folderURL)
        }
        deleteCourseFolder(courseIds: deselectedCourseIDs, sessionID: sessionID)
    }

    private func updateFileMetadata(courses: [OfflineCourseItem]) {
        var metadata = session.horizonOfflineSyncFileMetadata
        courses.flatMap(\.selectedFiles).forEach { file in
            metadata[file.id] = file.toDic()
        }
        session.horizonOfflineSyncFileMetadata = metadata
    }

    private func removeUnavailableFiles(courses: [OfflineCourseItem]) {
        courses.forEach { course in
            filesInteractor
                .removeUnavailableFiles(
                    courseId: course.id,
                    newFileIDs: course.selectedFiles.map(\.id),
                    sessionID: session.sessionID
                )
                .sink()
                .store(in: &subscriptions)
        }
    }
}
