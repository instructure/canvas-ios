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

class GetParentCalendarFilters: UseCase {
    struct APIResponse: Codable {
        let courses: [APICourse]
        let groups: [APIGroup]
    }
    typealias Model = CDCalendarFilterEntry
    typealias Response = APIResponse
    var cacheKey: String? { "calendar/filters/observing/\(observedUserId)" }
    var scope: Scope { .where((\CDCalendarFilterEntry.observedUserId).string, equals: observedUserId) }

    private var subscriptions = Set<AnyCancellable>()
    private let userName: String
    private let userId: String
    private let observedUserId: String

    init(
        currentUserName: String,
        currentUserId: String,
        observedStudentId: String
    ) {
        userName = currentUserName
        userId = currentUserId
        self.observedUserId = observedStudentId
    }

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let coursesRequest = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        )
        let coursesFetch = environment.api
            .exhaust(coursesRequest)
            .map { [observedUserId] in
                let courses = $0.body.filter {
                    $0.enrollments?.contains { $0.associated_user_id?.value == observedUserId } == true
                }
                return courses
            }

        let groupsRequest = GetGroupsRequest(context: .currentUser)
        let groupsFetch = environment.api.exhaust(groupsRequest)

        Publishers
            .CombineLatest(coursesFetch, groupsFetch)
            .map {
                APIResponse(
                    courses: $0.0,
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

    func write(response: APIResponse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }

        CDCalendarFilterEntry.save(
            userId: userId,
            userName: userName,
            courses: response.courses,
            groups: response.groups,
            observedUserId: observedUserId,
            in: client
        )
    }

    func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(scope: scope) as [CDCalendarFilterEntry])
    }
}
