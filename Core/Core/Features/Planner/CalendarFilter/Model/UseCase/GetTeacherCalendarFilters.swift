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

class GetTeacherCalendarFilters: UseCase {
    struct APIResponse: Codable {
        let courses: [APICourse]
        let groups: [APIGroup]
    }
    typealias Model = CDCalendarFilterEntry
    typealias Response = APIResponse

    enum Purpose {
        case viewing, creating

        fileprivate var filterPurpose: CDCalendarFilterPurpose {
            switch self {
            case .viewing: return .viewing
            case .creating: return .creating
            }
        }
    }

    var cacheKey: String? { "calendar/filters/teacher/\(purpose.filterPurpose.cacheToken)" }
    var scope: Scope {
        return .init(
            predicate: NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(key: (\CDCalendarFilterEntry.observedUserId).string, equals: nil),
                    NSPredicate(key: (\CDCalendarFilterEntry.rawPurpose).string,
                                equals: purpose.filterPurpose.rawValue)
                ]
            ),
            order: [
                NSSortDescriptor(key: (\CDCalendarFilterEntry.name).string, ascending: true)
            ]
        )
    }

    private var subscriptions = Set<AnyCancellable>()
    private let userName: String
    private let userId: String
    private let purpose: Purpose

    init(
        currentUserName: String,
        currentUserId: String,
        purpose: Purpose
    ) {
        userName = currentUserName
        userId = currentUserId
        self.purpose = purpose
    }

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        let groupsFetch = environment.api.exhaust(groupsRequest)

        let coursesFetch: AnyPublisher<[APICourse], Error>

        switch purpose {
        case .creating:
            coursesFetch = coursesAsTeacherFetch(env: environment)
        case .viewing:
            coursesFetch = currentCoursesFetch(env: environment)
        }

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

    func write(response: APIResponse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }

        CDCalendarFilterEntry.save(
            userId: userId,
            userName: userName,
            courses: response.courses,
            groups: response.groups,
            purpose: purpose.filterPurpose,
            in: client
        )
    }

    func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(scope: scope) as [CDCalendarFilterEntry])
    }
}

// MARK: - Fetch Publishers

private extension GetTeacherCalendarFilters {

    func currentCoursesFetch(env: AppEnvironment) -> AnyPublisher<[APICourse], Error> {
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [],
            includes: []
        )

        return env.api
            .exhaust(coursesRequest)
            .map { $0.body }
            .eraseToAnyPublisher()
    }

    func coursesAsTeacherFetch(env: AppEnvironment) -> AnyPublisher<[APICourse], Error> {
        let coursesRequest = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .teacher,
            state: [],
            perPage: 100
        )
        return env.api
            .exhaust(coursesRequest)
            .map { $0.body }
            .eraseToAnyPublisher()
    }
}
