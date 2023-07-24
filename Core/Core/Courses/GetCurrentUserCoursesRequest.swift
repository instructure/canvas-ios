//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct GetCurrentUserCoursesRequest: APIRequestable {
    public typealias Response = [APICourse]

    public let path = "courses"
    public var query: [APIQueryItem] {
        [
            .perPage(perPage),
            .optionalValue("enrollment_state", enrollmentState?.rawValue),
            .array("state", state.map { $0.rawValue }),
            .include(includes.map { $0.rawValue }),
        ]
    }

    private let enrollmentState: GetCoursesRequest.EnrollmentState?
    private let state: [GetCoursesRequest.State]
    private let includes: [GetCourseRequest.Include]
    private let perPage: Int

    public init(enrollmentState: GetCoursesRequest.EnrollmentState? = .active,
                state: [GetCoursesRequest.State] = [],
                includes: [GetCourseRequest.Include] = [],
                perPage: Int = 100
    ) {
        self.enrollmentState = enrollmentState
        self.state = state
        self.includes = includes
        self.perPage = perPage
    }
}
