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
import CoreData
import Foundation

/// Fetches and persists unread announcement counts for all enrolled courses.
///
/// ## Fetching strategy
///
/// **Phase 1 — First page (`GetUnreadCourseAnnouncementCountRequest`):**
/// A single `allCourses` query (no cursor) fetches the first page of announcements
/// for every course simultaneously. Most courses with fewer than `pageSize` unread
/// announcements are fully resolved here.
///
/// **Phase 2 — Subsequent pages (`GetUnreadAnnouncementsCountPageRequest`):**
/// For each course that reports `hasNextPage: true`, a dedicated `courses(ids:)` query
/// is fired with that course's own cursor. This ensures each cursor is applied only to
/// the connection it belongs to. All per-course requests for a given round are fired in
/// parallel; the process recurses until no course has a next page.
///
/// ## Persistence strategy
///
/// `write(response:urlResponse:to:)` upserts rather than replaces: it deletes only
/// entities whose course is absent from the new response, and updates the rest in place.
final class GetUnreadCourseAnnouncementCountsUseCase: UseCase {
    typealias Model = CDUnreadCourseAnnouncementCount
    typealias Response = [GetUnreadAnnouncementsCountResponse.CourseData]

    var cacheKey: String? { "unread-course-announcement-counts" }
    var scope: Scope { .all }

    private var cancellables = Set<AnyCancellable>()

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        Self.fetchAllPages(environment: environment)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        completionHandler(nil, nil, error)
                    }
                },
                receiveValue: { courses in
                    completionHandler(courses, nil, nil)
                }
            )
            .store(in: &cancellables)
    }

    func write(
        response: [GetUnreadAnnouncementsCountResponse.CourseData]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let courses = response else { return }

        var idsByCourseId: [String: Set<String>] = [:]
        for course in courses {
            idsByCourseId[course._id, default: []].formUnion(course.unreadAnnouncementIds)
        }

        let existing: [CDUnreadCourseAnnouncementCount] = client.fetch(scope: .all)
        for entity in existing where idsByCourseId[entity.courseId] == nil {
            client.delete(entity)
        }

        for (courseId, ids) in idsByCourseId {
            CDUnreadCourseAnnouncementCount.save(
                courseId: courseId,
                unreadAnnouncementIds: Array(ids),
                in: client
            )
        }
    }

    /// Fetches the first page for all courses, then recursively fetches additional
    /// pages for any course that has more results.
    private static func fetchAllPages(
        environment: AppEnvironment
    ) -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> {
        environment.api
            .makeRequest(GetUnreadCourseAnnouncementCountRequest())
            .flatMap { response -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> in
                let firstPage = response.body.data.allCourses
                let pendingCourseCursors = firstPage.compactMap { course -> (courseId: String, cursor: String)? in
                    guard let cursor = course.discussionsConnection.pageInfo?.nextCursor else { return nil }
                    return (course._id, cursor)
                }
                guard !pendingCourseCursors.isEmpty else {
                    return Just(firstPage).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return fetchCursorRound(pendingCourseCursors, environment: environment)
                    .map { firstPage + $0 }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Fires one targeted request per (courseId, cursor) pair in parallel, then
    /// recurses for any course that still has a next page.
    private static func fetchCursorRound(
        _ courseCursors: [(courseId: String, cursor: String)],
        environment: AppEnvironment
    ) -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> {
        let publishers = courseCursors.map { courseId, cursor in
            environment.api
                .makeRequest(GetUnreadAnnouncementsCountPageRequest(courseId: courseId, cursor: cursor))
                .map { $0.body.data.courses }
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.flatMap { $0 } }
            .flatMap { courses -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> in
                let nextCourseCursors = courses.compactMap { course -> (courseId: String, cursor: String)? in
                    guard let cursor = course.discussionsConnection.pageInfo?.nextCursor else { return nil }
                    return (course._id, cursor)
                }
                guard !nextCourseCursors.isEmpty else {
                    return Just(courses).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return fetchCursorRound(nextCourseCursors, environment: environment)
                    .map { courses + $0 }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
