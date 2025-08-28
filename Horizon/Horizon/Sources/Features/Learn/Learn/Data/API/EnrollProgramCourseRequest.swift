//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct EnrollProgramCourseRequest: APIGraphQLRequestable {
    public typealias Response = GetHProgramsResponse
    public let variables: Input

    public struct Input: Codable, Equatable {
        let progressId: String
    }

    public var path: String { "/graphql" }
    public static let operationName: String = "ProgramProgressGQL"
    public var shouldAddNoVerifierQuery: Bool = false

    public var headers: [String: String?] = [
         HttpHeader.accept: "application/json"
    ]

    init(progressId: String) {
        self.variables = .init(progressId: progressId)
    }
    public static let query = """
        mutation \(operationName)($progressId: String!) {
        enroll(progressId: $progressId) {
              id
            }
        }
        """
}
