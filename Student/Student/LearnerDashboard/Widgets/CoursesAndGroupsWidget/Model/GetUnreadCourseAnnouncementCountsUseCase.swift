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
        let existing: [CDUnreadCourseAnnouncementCount] = client.fetch(scope: .all)
        existing.forEach { client.delete($0) }

        guard let courses = response else { return }

        var idsByCourseId: [String: Set<String>] = [:]
        for course in courses {
            idsByCourseId[course._id, default: []].formUnion(course.unreadAnnouncementIds)
        }

        for (courseId, ids) in idsByCourseId {
            CDUnreadCourseAnnouncementCount.save(
                courseId: courseId,
                unreadAnnouncementIds: Array(ids),
                in: client
            )
        }
    }

    private static func fetchAllPages(
        environment: AppEnvironment
    ) -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> {
        environment.api
            .makeRequest(GetUnreadAnnouncementsCountRequest())
            .flatMap { response -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> in
                let firstPage = response.body.data.allCourses
                let pendingCursors = firstPage.compactMap { $0.discussionsConnection.pageInfo?.nextCursor }
                guard !pendingCursors.isEmpty else {
                    return Just(firstPage).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return fetchCursorRound(pendingCursors, environment: environment)
                    .map { firstPage + $0 }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private static func fetchCursorRound(
        _ cursors: [String],
        environment: AppEnvironment
    ) -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> {
        let publishers = cursors.map { cursor in
            environment.api
                .makeRequest(GetUnreadAnnouncementsCountRequest(cursor: cursor))
                .map { $0.body.data.allCourses }
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.flatMap { $0 } }
            .flatMap { courses -> AnyPublisher<[GetUnreadAnnouncementsCountResponse.CourseData], Error> in
                let nextCursors = courses.compactMap { $0.discussionsConnection.pageInfo?.nextCursor }
                guard !nextCursors.isEmpty else {
                    return Just(courses).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return fetchCursorRound(nextCursors, environment: environment)
                    .map { courses + $0 }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
