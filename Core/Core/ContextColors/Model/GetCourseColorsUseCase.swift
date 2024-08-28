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

public class GetCourseColorsUseCase: UseCase {
    public typealias Model = ContextColor
    public typealias Response = APIResponses

    public struct APIResponses: Codable {
        let courses: [APICourse]
        let customColors: APICustomColors
    }

    public var cacheKey: String? = "course_colors"

    private var subscriptions = Set<AnyCancellable>()

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        let coursesRequest = GetCoursesRequest()
        let customColorsRequest = GetCustomColorsRequest()

        Publishers.CombineLatest(
            environment.api.exhaust(coursesRequest),
            environment.api.makeRequest(customColorsRequest, refreshToken: true)
        )
        .map { coursesResponse, customColorsResponse in
            APIResponses(courses: coursesResponse.body, customColors: customColorsResponse.body)
        }
        .sink { _ in
        } receiveValue: { responses in
            completionHandler(responses, nil, nil)
        }
        .store(in: &subscriptions)
    }

    public func write(
        response: APIResponses?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else { return }
        ContextColor.save(response, in: client)
    }
}
