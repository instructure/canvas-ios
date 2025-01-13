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

public struct APICommentLibraryRequest: APIGraphQLRequestable {
    public typealias Response = APICommentLibraryResponse

    static let operationName = "CommentLibraryQuery"
    static let query = """
        query \(operationName)($userId: ID!) {
            user: legacyNode(_id: $userId, type: User, $pageSize: Int!, $cursor: String) {
                ... on User {
                    id: _id
                    commentBankItems: commentBankItemsConnection(query: "", first: $pageSize, after: $cursor) {
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
        public let userId: String
        public let cursor: String?
        public let pageSize: Int
    }

    public let variables: Variables

    public init(userId: String, pageSize: Int = 10, cursor: String? = nil) {
        variables = Variables(userId: userId, cursor: cursor, pageSize: pageSize)
    }

    public func getNext(from response: APICommentLibraryResponse) -> APICommentLibraryRequest? {
        guard let pageInfo = response.data.user.commentBankItems.pageInfo,
              pageInfo.hasNextPage
        else { return nil }

        return APICommentLibraryRequest(
            userId: variables.userId,
            pageSize: variables.pageSize,
            cursor: pageInfo.endCursor
        )
    }
}
