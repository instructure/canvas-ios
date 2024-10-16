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

class GetStudentCalendarFilters: UseCase {
    struct APIResponse: Codable {
        let courses: [APICourse]
        let groups: [APIGroup]
    }
    typealias Model = CDCalendarFilterEntry
    typealias Response = APIResponse

    let cacheKey: String? = "calendar/filters"
    let scope: Scope = {
        let unknownPurpose = CDCalendarFilterPurpose.unknown.rawValue
        return .init(
            predicate: NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    .init(key: (\CDCalendarFilterEntry.observedUserId).string, equals: nil),
                    .init(key: (\CDCalendarFilterEntry.rawPurpose).string, equals: unknownPurpose)
                ]
            ),
            order: [
                NSSortDescriptor(key: (\CDCalendarFilterEntry.name).string, ascending: true)
            ]
        )
    }()

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
            .validateGroups()
            .map { (courses, groups) in
                return APIResponse(courses: courses, groups: groups)
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
        guard let response else { return }

        // save user filter
        CDCalendarFilterEntry.save(
            context: .user(userId),
            name: userName,
            in: client
        )

        // save course filters
        response.courses.forEach { course in
            CDCalendarFilterEntry.save(
                context: .course(course.id.value),
                name: course.name ?? "",
                in: client
            )
        }

        // save group filters
        response.groups.forEach { group in
            CDCalendarFilterEntry.save(
                context: .group(group.id.value),
                name: group.name,
                in: client
            )
        }
    }

    func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(scope: scope) as [CDCalendarFilterEntry])
    }
}

// MARK: - Groups Validation

extension Publisher where Output == ([APICourse], (body: [APIGroup], urlResponse: HTTPURLResponse?)) {

    func validateGroups() -> Publishers.Map<Self, ([APICourse], [APIGroup])> {
        map { (courses, groups) in
            let validCourseIDs = courses.map { $0.id }
            /// If a course's end date has passed and "Restrict students from viewing course after course end date" is checked
            /// then fetching events for a group in this course will give 403 unauthorized.
            /// To be on the safe side we drop all groups without a valid course.
            let filteredGroups = groups.body.dropCourseGroupsWithoutValidCourses(validCourseIDs: validCourseIDs)
            return (courses, filteredGroups)
        }
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
