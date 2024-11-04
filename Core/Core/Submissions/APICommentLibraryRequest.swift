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

    public static let operationName = "CommentLibraryQuery"
    public static let query = """
        query \(operationName)($userId: ID!) {
            user: legacyNode(_id: $userId, type: User) {
                ... on User {
                    id: _id
                    commentBankItems: commentBankItemsConnection(query: "") {
                        nodes {
                            comment: comment
                            id: _id
                        }
                    }
                }
            }
        }
        """

    public struct Variables: Codable, Equatable {
        public let userId: String
    }

    public let variables: Variables

    public init(userId: String) {
        variables = Variables(userId: userId)
    }
}
