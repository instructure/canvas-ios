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

import Foundation

public struct GetTimeSpentWidgetRequest: APIGraphQLRequestable {
    public typealias Response = GetTimeSpentWidgetResponse
    public typealias Variables = Input
    public let variables: Input = .init()
    public struct Input: Codable, Equatable { }
    public var path: String { "/graphql" }
    public var shouldAddNoVerifierQuery: Bool = false

    public var headers: [String: String?] = [
        HttpHeader.accept: "application/json"
    ]
    public init() {}

    public static let operationName: String = "TimeSpentWidget"
    public static let query = """
    query \(operationName) {
        widgetData(
          widgetType: "time_spent_details",
          dataScope: "learner",
          timeSpan: {
            type: PAST_7_DAYS
          }
        ) {
          data
          lastModifiedDate
        }
      }
    """
}
