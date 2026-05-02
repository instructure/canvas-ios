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
import Core
import Foundation

final class HCourseSyncInteractorAdapter: CourseSyncInteractor {
    private let wrapped: HCourseSyncInteractor
    private var completionSubscription: AnyCancellable?

    init(wrapped: HCourseSyncInteractor) {
        self.wrapped = wrapped
    }

    func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[CourseSyncEntry], Never> {
        let courses = buildCourses(from: AppEnvironment.shared.userDefaults ?? .fallback)
        completionSubscription = wrapped.progressPublisher
            .filter(\.isComplete)
            .first()
            .sink { _ in
                NotificationCenter.default.post(name: .OfflineSyncCompleted, object: nil)
            }

        wrapped.downloadContent(courses: courses, environment: AppEnvironment.shared)
        return Just(entries).eraseToAnyPublisher()
    }

    func cleanContent(for courseIds: [CourseSyncID]) -> AnyPublisher<Void, Never> {
        guard let sessionID = AppEnvironment.shared.currentSession?.uniqueID else {
            return Just(()).eraseToAnyPublisher()
        }
        let courses = buildCourses(from: AppEnvironment.shared.userDefaults ?? .fallback)
        return courses.map(\.id).publisher
            .map { courseId in
                let folderURL = URL.Directories.documents.appendingPathComponent(
                    URL.Paths.Offline.courseFolder(sessionID: sessionID, courseId: courseId)
                )
                try? FileManager.default.removeItem(at: folderURL)
            }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func cancel() {
        completionSubscription?.cancel()
        wrapped.cancelSync()
    }

    private func buildCourses(from sessionDefaults: SessionDefaults) -> [OfflineCourseItem] {
        let types = sessionDefaults.offlineSyncSelections.compactMap { OfflineType.parse(path: $0) }
        let fileMetadata = sessionDefaults.horizonOfflineSyncFileMetadata

        var courseFilesMap: [String: [String]] = [:]
        var courseOnlyIDs: Set<String> = []

        for type in types {
            switch type {
            case .course(let id):
                courseOnlyIDs.insert(id)
            case .file(let courseID, let fileID):
                courseFilesMap[courseID, default: []].append(fileID)
            default:
                break
            }
        }

        return courseOnlyIDs.union(Set(courseFilesMap.keys)).map { courseID in
            let fileItems = (courseFilesMap[courseID] ?? []).compactMap { fileID -> OfflineFileItem? in
                guard let info = fileMetadata[fileID] else { return nil }
                return OfflineFileItem(
                    id: fileID,
                    name: info["name"] as? String ?? "",
                    size: "",
                    sizeInBytes: info["sizeInBytes"] as? Double ?? 0,
                    isSelected: true,
                    mimeClass: info["mimeClass"] as? String ?? "",
                    courseID: courseID
                )
            }
            return OfflineCourseItem(
                id: courseID,
                name: "",
                size: nil,
                isExpanded: false,
                isSelected: fileItems.isEmpty,
                subItems: fileItems
            )
        }
    }
}
