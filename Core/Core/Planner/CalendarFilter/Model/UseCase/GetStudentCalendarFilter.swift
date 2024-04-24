//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import CoreData
import Combine
import SwiftUI

class GetStudentCalendarFilter: UseCase {
    struct APIResponse: Codable {
        let courses: [APICourse]
        let groups: [APIGroup]
    }
    typealias Model = CDCalendarFilter
    typealias Response = APIResponse
    let cacheKey: String? = "calendar/filters"
    let scope: Scope = .all

    private var subscriptions = Set<AnyCancellable>()
    private let userName: String
    private let userId: String

    init(currentUserName: String, currentUserId: String) {
        userName = currentUserName
        userId = currentUserId
    }

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: []
        )
        let coursesFetch = environment.api.makeRequest(coursesRequest)

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        let groupsFetch = environment.api.makeRequest(groupsRequest)

        Publishers
            .CombineLatest(coursesFetch, groupsFetch)
            .map {
                APIResponse(
                    courses: $0.0.body,
                    groups: $0.1.body
                )
            }
            .first()
            .sink { completion in
                if case .failure(let error) = completion {
                    completionHandler(nil, nil, error)
                }
            } receiveValue: { response in
                completionHandler(response, nil, nil)
            }
            .store(in: &subscriptions)
    }

    func write(
        response: APIResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let courses = response?.courses,
              let groups = response?.groups
        else {
            return
        }

        var filters: [CDCalendarFilterEntry] = []

        filters.append({
            let filter: CDCalendarFilterEntry = client.insert()
            filter.context = .user(userId)
            filter.name = userName
            return filter
        }())

        filters.append(contentsOf: {
            courses.map { course in
                let filter: CDCalendarFilterEntry = client.insert()
                filter.context = .course(course.id.rawValue)
                filter.name = course.name ?? ""
                return filter
            }
        }())

        filters.append(contentsOf: {
            groups.map { group in
                let filter: CDCalendarFilterEntry = client.insert()
                filter.context = .group(group.id.rawValue)
                filter.name = group.name
                return filter
            }
        }())

        let filter: CDCalendarFilter = client.first(scope: .all) ?? client.insert()
        filter.entries = Set(filters)
    }
}
