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

final class RedwoodCreateNoteMutation: APIGraphQLRequestable, RedwoodProxyRequestable {
    typealias Response = RedwoodCreateNoteMutationResponse
    public let innerVariables: NewCourseNoteInput
    public static let operationName: String = "RedwoodCreateNote"
    public static let innerOperationName: String = "CreateNote"

    var path: String { "/graphql" }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": RedwoodCreateNoteMutation.operationName,
            HttpHeader.accept: "application/json"
        ]
    }

    public init(note: NewRedwoodNote) {
        self.innerVariables = NewCourseNoteInput(input: note)
    }

    public static var innerQuery: String {
        """
        mutation CreateNote($input: CreateNoteInput!) {
            createNote(input: $input) {
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

// MARK: - Models

extension RedwoodCreateNoteMutation {
    struct NewCourseNoteInput: Codable, Equatable {
        let input: NewRedwoodNote
    }
}

struct RedwoodCreateNoteMutationResponse: Codable {
    let data: Executer

    struct Executer: Codable {
        let executeRedwoodQuery: NoteData
    }

    struct NoteData: Codable {
        let data: RedwoodCreateNote
    }

    struct RedwoodCreateNote: Codable {
        let createNote: RedwoodNote
    }
}
