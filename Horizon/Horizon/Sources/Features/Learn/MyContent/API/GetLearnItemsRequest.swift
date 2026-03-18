//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Core

public struct GetLearnItemsRequest: APIGraphQLPagedRequestable {
    public typealias Response = GetLearnItemsResponse
    public typealias Variables = VariablesContainer

    public struct VariablesContainer: Codable, Equatable {
        let input: InputParams
    }

    public struct InputParams: Codable, Equatable {
        let searchTerm: String?
        let cursor: String?
        let forward: Bool
        let itemTypes: [String]?
        let status: [String]
        let sortBy: String?
        let limit: Int
    }

    public let variables: VariablesContainer
    public var path: String { "/graphql" }
    public var headers: [String: String?] = [
        HttpHeader.accept: "application/json"
    ]

    public static let operationName: String = "LearnItems"

    public init(
        searchTerm: String? = nil,
        cursor: String? = nil,
        forward: Bool = true,
        itemTypes: [String]? = nil,
        sortBy: String? = nil,
        limit: Int = 100,
        status: [String]
    ) {
        let inputParams = InputParams(
            searchTerm: searchTerm,
            cursor: cursor,
            forward: forward,
            itemTypes: itemTypes,
            status: status,
            sortBy: sortBy,
            limit: limit
        )
        self.variables = VariablesContainer(input: inputParams)
    }

    public static var query: String {
        """
        query \(operationName)($input: LearnItemsQueryInput) {
            learnItems(input: $input) {
              items {
                __typename
                ... on ProgramEnrollmentItemGQL {
                  id
                  name
                  itemType
                  position
                  startDate
                  endDate
                  enrolledAt
                  completionPercentage
                  status
                  description
                  variant
                  estimatedDurationMinutes
                  courseCount
                }
                ... on CourseEnrollmentItemGQL {
                  id
                  name
                  itemType
                  position
                  startAt
                  endAt
                  enrolledAt
                  completionPercentage
                  requirementCount
                  requirementCompletedCount
                  completedAt
                  grade
                  imageUrl
                  workflowState
                  lastActivityAt
                }
              }
              pageInfo {
                nextCursor
                previousCursor
                hasNextPage
                hasPreviousPage
                totalCount
                pageCursors {
                  page
                  cursor
                }
              }
            }
          }
        """
    }

    public func nextPageRequest(from response: GetLearnItemsResponse) -> GetLearnItemsRequest? {
        guard response.data?.learnItems?.pageInfo?.hasNextPage == true else {
            return nil
        }
        let nextCursor = response.data?.learnItems?.pageInfo?.nextCursor
        return GetLearnItemsRequest(
            searchTerm: variables.input.searchTerm,
            cursor: nextCursor,
            forward: variables.input.forward,
            itemTypes: variables.input.itemTypes,
            sortBy: variables.input.sortBy,
            limit: variables.input.limit,
            status: variables.input.status
        )
    }
}
