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

final class RedwoodUpdateNoteMutation: APIGraphQLRequestable, RedwoodProxyRequestable {
    typealias Response = RedwoodUpdateNoteMutationResponse

    public let innerVariables: UpdateNoteVariables
    public static let operationName: String = "RedwoodUpdateNote"
    public static let innerOperationName: String = "UpdateNote"

    var path: String { "/graphql" }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": RedwoodUpdateNoteMutation.operationName,
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        id: String,
        userText: String,
        reaction: [String],
        highlightData: NotebookHighlight?
    ) {
        self.innerVariables = UpdateNoteVariables(
            id: id,
            input: UpdateRedwoodNote(
                userText: userText,
                reaction: reaction,
                highlightData: highlightData
            )
        )
    }

    public static var innerQuery: String {
        """
        mutation UpdateNote($id: String!, $input: UpdateNoteInput!) {
            updateNote(id: $id, input: $input) {
                id
                courseId
                objectId
                objectType
                userText
                reaction
                updatedAt
                highlightData
            }
        }
        """
    }
}

// MARK: - Request Models

extension RedwoodUpdateNoteMutation {
    struct UpdateNoteVariables: Codable, Equatable {
        let id: String
        let input: UpdateRedwoodNote
    }
}

struct RedwoodUpdateNoteMutationResponse: Codable {
    let data: Response

    struct Response: Codable {
        let executeRedwoodQuery: RedwoodProxyDataWrapper
    }

    struct RedwoodProxyDataWrapper: Codable {
        let data: UpdateNoteContainer
    }

    struct UpdateNoteContainer: Codable {
        let updateNote: RedwoodNote
    }
}
