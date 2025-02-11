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

public struct APICommentLibraryRequest: APIGraphQLPagedRequestable {
    public typealias Response = APICommentLibraryResponse

    static let operationName = "CommentLibraryQuery"
    static let query = """
        query \(operationName)($query: String, $userId: ID!, $pageSize: Int!, $cursor: String) {
            user: legacyNode(_id: $userId, type: User) {
                ... on User {
                    id: _id
                    commentBankItems: commentBankItemsConnection(query: $query, first: $pageSize, after: $cursor) {
                        nodes {
                            comment: comment
                            id: _id
                        }
                        pageInfo {
                            endCursor
                            hasNextPage
                        }
                    }
                }
            }
        }
        """

    public struct Variables: Codable, Equatable {
        public let query: String
        public let userId: String
        public let cursor: String?
        public let pageSize: Int
    }

    public let variables: Variables

    public init(query: String, userId: String, pageSize: Int = 20, cursor: String? = nil) {
        variables = Variables(
            query: query,
            userId: userId,
            cursor: cursor,
            pageSize: pageSize
        )
    }

    public func nextPageRequest(from response: APICommentLibraryResponse) -> APICommentLibraryRequest? {
        guard let pageInfo = response.data.user.commentBankItems.pageInfo,
              pageInfo.hasNextPage
        else { return nil }

        return APICommentLibraryRequest(
            query: variables.query,
            userId: variables.userId,
            pageSize: variables.pageSize,
            cursor: pageInfo.endCursor
        )
    }
}
