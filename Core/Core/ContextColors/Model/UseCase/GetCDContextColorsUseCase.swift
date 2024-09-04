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

import Combine
import CoreData

public class GetCDContextColorsUseCase: UseCase {
    public typealias Model = CDContextColor
    public typealias Response = APIContextColorsResponse

    public var cacheKey: String? { "context_colors" }
    public var ttl: TimeInterval { 24 * 60 * 60 }

    private var subscriptions = Set<AnyCancellable>()

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let coursesRequest = GetCoursesRequest()
        let groupsRequest = GetGroupsRequest(context: .currentUser)
        let customColorsRequest = GetCustomColorsRequest()
        let dashboardCardsRequest = GetDashboardCardsRequest()

        // TODO: Fetch only required fields with GraphQL?
        Publishers.CombineLatest4(
            environment.api.exhaust(coursesRequest),
            environment.api.exhaust(groupsRequest),
            environment.api.makeRequest(customColorsRequest, refreshToken: true),
            environment.api.makeRequest(dashboardCardsRequest)
        )
        .map { coursesResponse, groupsResponse, customColorsResponse, dashboardCardsResponse in
            APIContextColorsResponse(
                courses: coursesResponse.body,
                groups: groupsResponse.body,
                customColors: customColorsResponse.body,
                dashboardCards: dashboardCardsResponse.body
            )
        }
        .sink { _ in
        } receiveValue: { responses in
            completionHandler(responses, nil, nil)
        }
        .store(in: &subscriptions)
    }

    public func write(
        response: APIContextColorsResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else { return }
        CDContextColor.save(response, in: client)
    }
}
