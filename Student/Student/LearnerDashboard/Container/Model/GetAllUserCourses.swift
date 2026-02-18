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
import CoreData
import Foundation

class GetAllUserCourses: UseCase {
    typealias Model = Course
    typealias Response = [APICourse]

    let cacheKey: String? = "all-user-courses"
    let scope: Scope = .all

    private static let includes = GetCourseRequest.defaultIncludes + [.tabs]

    let activeRequest = GetCurrentUserCoursesRequest(
        enrollmentState: .active,
        state: [.current_and_concluded],
        includes: includes
    )
    let completedRequest = GetCurrentUserCoursesRequest(
        enrollmentState: .completed,
        state: [.current_and_concluded],
        includes: includes
    )
    let invitedRequest = GetCurrentUserCoursesRequest(
        enrollmentState: .invited_or_pending,
        state: [.current_and_concluded],
        includes: includes
    )

    init() {}

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let group = DispatchGroup()
        var activeCourses: [APICourse] = []
        var completedCourses: [APICourse] = []
        var invitedCourses: [APICourse] = []
        var requestError: Error?

        group.enter()
        environment.api.makeRequest(activeRequest) { response, _, error in
            if let courses = response {
                activeCourses = courses
            }
            if let error {
                requestError = error
            }
            group.leave()
        }

        group.enter()
        environment.api.makeRequest(completedRequest) { response, _, error in
            if let courses = response {
                completedCourses = courses
            }
            if let error {
                requestError = error
            }
            group.leave()
        }

        group.enter()
        environment.api.makeRequest(invitedRequest) { response, _, error in
            if let courses = response {
                invitedCourses = courses
            }
            if let error {
                requestError = error
            }
            group.leave()
        }

        group.notify(queue: .global()) {
            if let error = requestError {
                completionHandler(nil, nil, error)
            } else {
                let allCourses = activeCourses + completedCourses + invitedCourses
                completionHandler(allCourses, nil, nil)
            }
        }
    }

    func write(
        response: [APICourse]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else { return }

        let idsToKeep = Set(response.map { $0.id.value })
        let existingCourses: [Course] = client.fetch(scope: scope)
        let coursesToDelete = existingCourses.filter { !idsToKeep.contains($0.id) }
        client.delete(coursesToDelete)

        response.forEach { Course.save($0, in: client) }
    }
}
