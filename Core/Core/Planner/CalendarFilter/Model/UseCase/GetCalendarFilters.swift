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

class GetCalendarFilters: UseCase {
    struct APIResponse: Codable {
        let courses: [APICourse]
        let groups: [APIGroup]
    }
    typealias Model = CDCalendarFilterEntry
    typealias Response = APIResponse
    let cacheKey: String? = "calendar/filters"
    let scope: Scope = .where((\CDCalendarFilterEntry.observedUserId).string, equals: nil)

    private var subscriptions = Set<AnyCancellable>()
    private let userName: String
    private let userId: String
    private let states: [GetCoursesRequest.State]
    private let filterUnpublishedCourses: Bool

    init(
        currentUserName: String,
        currentUserId: String,
        states: [GetCoursesRequest.State],
        filterUnpublishedCourses: Bool
    ) {
        userName = currentUserName
        userId = currentUserId
        self.states = states
        self.filterUnpublishedCourses = filterUnpublishedCourses
    }

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: states,
            includes: []
        )
        let coursesFetch = environment.api
            .exhaust(coursesRequest)
            .map { [filterUnpublishedCourses] in
                let courses = $0.body

                if filterUnpublishedCourses {
                    return courses.filter { $0.workflow_state != .unpublished }
                } else {
                    return courses
                }
            }

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        let groupsFetch = environment.api.exhaust(groupsRequest)

        Publishers
            .CombineLatest(coursesFetch, groupsFetch)
            .map { (courses, groups) in
                let validCourseIDs = courses.map { $0.id }
                /// If a course's end date has passed and "Restrict students from viewing course after course end date" is checked
                /// then fetching events for a group in this course will give 403 unauthorized.
                /// To be on the safe side we drop all courses without a valid course.
                let filteredGroups = groups.body.dropCourseGroupsWithoutValidCourses(validCourseIDs: validCourseIDs)
                return APIResponse(
                    courses: courses,
                    groups: filteredGroups
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

        let filter: CDCalendarFilterEntry = client.insert()
        filter.context = .user(userId)
        filter.name = userName

        courses.forEach { course in
            let filter: CDCalendarFilterEntry = client.insert()
            filter.context = .course(course.id.rawValue)
            filter.name = course.name ?? ""
        }

        groups.forEach { group in
            let filter: CDCalendarFilterEntry = client.insert()
            filter.context = .group(group.id.rawValue)
            filter.name = group.name
        }
    }

    func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(scope: scope) as [CDCalendarFilterEntry])
    }
}

private extension Array where Element == APIGroup {

    func dropCourseGroupsWithoutValidCourses(validCourseIDs: [ID]) -> [Element] {
        filter { group in
            switch group.groupType {
            case .account:
                return true
            case .course(let courseId):
                return validCourseIDs.contains(courseId)
            }
        }
    }
}
