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

class RedwoodUpdateNoteMutation: APIGraphQLRequestable {
    let variables: Input
    private let jwt: String

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "UpdateNote",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        jwt: String,
        id: String,
        userText: String? = nil,
        reaction: [String]? = nil
    ) {
        self.variables = Input(id: id, input: .init(userText: userText, reaction: reaction))
        self.jwt = jwt
    }

    public static let operationName: String = "UpdateNote"
    public static var query: String = """
    mutation \(operationName)($id: String!, $input: UpdateNoteInput!) {
        updateNote(id: $id, input: $input) {
            id
            courseId
            objectId
            objectType
            userText
            reaction
            createdAt
        }
    }
    """

    typealias Response = RedwoodUpdateNoteMutationResponse

    struct Input: Codable, Equatable {
        let id: String
        let input: UpdateNoteInput
    }

    struct UpdateNoteInput: Codable, Equatable {
        let userText: String?
        let reaction: [String]?
        // let highlightData: [String: Any]?
    }
}

// MARK: - Codeables

struct RedwoodUpdateNoteMutationResponse: Codable {
    let data: UpdateNote

    struct UpdateNote: Codable {
        let updateNote: RedwoodNote
    }
}
