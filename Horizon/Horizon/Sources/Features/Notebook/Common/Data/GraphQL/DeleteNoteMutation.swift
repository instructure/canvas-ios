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

final class RedwoodDeleteNoteMutation: APIGraphQLRequestable, RedwoodProxyRequestable {
    typealias Response = RedwoodDeleteNoteMutationResponse

    public let innerVariables: DeleteNoteInput
    public static let operationName: String = "RedwoodDeleteNote"
    public static let innerOperationName: String = "DeleteNote"

    var path: String { "/graphql" }
    var headers: [String: String?] {
        [
            "x-apollo-operation-name": RedwoodDeleteNoteMutation.operationName,
            HttpHeader.accept: "application/json"
        ]
    }

    public init(id: String) {
        self.innerVariables = DeleteNoteInput(id: id)
    }

    public static var innerQuery: String {
        """
        mutation DeleteNote($id: String!) {
            deleteNote(id: $id)
        }
        """
    }
}

// MARK: - Request Models

extension RedwoodDeleteNoteMutation {
    struct DeleteNoteInput: CodableEquatable {
        let id: String
    }
}

struct RedwoodDeleteNoteMutationResponse: Codable {
    let data: Response
    struct Response: Codable {
        let executeRedwoodQuery: RedwoodProxyDataWrapper
    }

    struct RedwoodProxyDataWrapper: Codable {
        let data: DeleteNoteContainer
    }

    struct DeleteNoteContainer: Codable {
        let deleteNote: String
    }
}
