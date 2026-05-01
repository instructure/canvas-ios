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

enum HSyncCourseState: Equatable {
    case downloading
    case downloaded
}

struct HCoursePageProgress {
    let courseID: String
    let state: HSyncCourseState
}

struct HPageDownloadProgress {
    static let bytesPerPage = 100_000

    let courseProgresses: [HCoursePageProgress]
    let totalSize: Int
    let downloadedSize: Int

    static let zero = HPageDownloadProgress(courseProgresses: [], totalSize: 0, downloadedSize: 0)
}

protocol HCourseSyncPagesInteractor {
    func getPages(courseIds: [String]) -> AnyPublisher<HPageDownloadProgress, Error>
    func cancelDownloads()
    func deletePages(courseIds: [String], sessionID: String)
}

final class HCourseSyncPagesInteractorLive: HCourseSyncPagesInteractor {
    // MARK: - Private types

    private typealias CourseProgressEntry = (downloaded: Int, total: Int)
    private typealias CourseUpdate = (courseId: String, pagesDownloaded: Int, totalPages: Int)

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let htmlParser: HTMLParser
    private let fileManager: FileManager

    // MARK: - Init

    init(htmlParser: HTMLParser, fileManager: FileManager = .default) {
        self.htmlParser = htmlParser
        self.fileManager = fileManager
    }

    func cancelDownloads() {
        subscriptions.removeAll()
    }

    func deletePages(courseIds: [String], sessionID: String) {
        courseIds.forEach { courseId in
            let folderURL = URL.Paths.Offline.courseSectionFolderURL(
                sessionId: sessionID,
                courseId: courseId,
                sectionName: "pages"
            )
            try? fileManager.removeItem(at: folderURL)
        }
    }

    func getPages(courseIds: [String]) -> AnyPublisher<HPageDownloadProgress, Error> {
        guard courseIds.isNotEmpty else {
            return Just(.zero).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.MergeMany(courseIds.map { getPagesForSingleCourse(courseId: $0) })
            .scan([String: CourseProgressEntry]()) { courseProgressMap, courseUpdate in
                var updatedMap = courseProgressMap
                updatedMap[courseUpdate.courseId] = (courseUpdate.pagesDownloaded, courseUpdate.totalPages)
                return updatedMap
            }
            .map(buildDownloadProgress(from:))
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func getPagesForSingleCourse(courseId: String) -> AnyPublisher<CourseUpdate, Error> {
        let courseSyncID = CourseSyncID(value: courseId)
        let context = Context(.course, id: courseId)
        return Publishers.Zip(
            ReactiveStore(useCase: GetFrontPage(context: context)).getEntities(ignoreCache: true).first(),
            ReactiveStore(useCase: GetPages(context: context)).getEntities(ignoreCache: true).first()
        )
        .flatMap { [weak self] (frontPages, pages) -> AnyPublisher<CourseUpdate, Error> in
            guard let self else { return Empty().eraseToAnyPublisher() }
            var seenIDs = Set<String>()
            let uniquePages = (frontPages + pages).filter { seenIDs.insert($0.id).inserted }
            return parsePagesWithProgress(uniquePages, courseId: courseId, courseSyncID: courseSyncID)
        }
        .eraseToAnyPublisher()
    }

    private func parsePagesWithProgress(
        _ pages: [Page],
        courseId: String,
        courseSyncID: CourseSyncID
    ) -> AnyPublisher<CourseUpdate, Error> {
        let totalPageCount = pages.count

        guard totalPageCount > 0 else {
            return Just((courseId: courseId, pagesDownloaded: 0, totalPages: 0))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Publishers.Sequence(sequence: pages)
            .setFailureType(to: Error.self)
            .flatMap(maxPublishers: .max(5)) { [htmlParser] page in
                htmlParser.parse(page.body, resourceId: page.id, courseId: courseSyncID, baseURL: page.htmlURL)
                    .map { _ in 1 }
            }
            .scan(0) { $0 + $1 }
            .prepend(0)
            .map { completedCount in (courseId: courseId, pagesDownloaded: completedCount, totalPages: totalPageCount) }
            .eraseToAnyPublisher()
    }
    
    private func buildDownloadProgress(from courseProgressMap: [String: CourseProgressEntry]) -> HPageDownloadProgress {
        let courseProgresses = courseProgressMap.map { courseID, progress -> HCoursePageProgress in
            let state: HSyncCourseState =
                (progress.total == 0 || progress.downloaded >= progress.total)
                ? .downloaded
                : .downloading
            return HCoursePageProgress(courseID: courseID, state: state)
        }
        let totalSize = courseProgressMap.values.reduce(0) { $0 + $1.total * HPageDownloadProgress.bytesPerPage }
        let downloadedSize = courseProgressMap.values.reduce(0) { $0 + $1.downloaded * HPageDownloadProgress.bytesPerPage }
        return HPageDownloadProgress(
            courseProgresses: courseProgresses,
            totalSize: totalSize,
            downloadedSize: downloadedSize
        )
    }
}
