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

class RedwoodCreateNoteMutation: APIGraphQLRequestable {
    let variables: NewCourseNoteInput

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "CreateNote",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(note: NewRedwoodNote) {
        self.variables = NewCourseNoteInput(input: note)
    }

    public static let operationName: String = "CreateNote"
    public static var query: String = """
    mutation \(operationName)($input: CreateNoteInput!) {
        createNote(input: $input) {
            id
            courseId
            objectId
            objectType
            userText
            reaction
            createdAt
            highlightData
        }
    }
    """

    typealias Response = RedwoodCreateNoteMutationResponse
}

struct NewCourseNoteInput: Codable, Equatable {
    let input: NewRedwoodNote
}

// MARK: - Codeables

struct RedwoodCreateNoteMutationResponse: Codable {
    let data: RedwoodCreateNote
}

struct RedwoodCreateNote: Codable {
    let createNote: RedwoodNote
}
