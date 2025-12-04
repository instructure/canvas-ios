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

public struct RedwoodFetchNotesQueryResponse: Codable, PagedResponse {
    public var page: [ResponseEdge] { data.notes.edges }
    public typealias Page = [ResponseEdge]

    let data: ResponseData

    public struct ResponseData: Codable {
        let notes: ResponseNotes
    }

    public struct ResponseNotes: Codable, Equatable {
        let edges: [ResponseEdge]
        let pageInfo: PageInfo
    }

    public struct ResponseEdge: Codable, Equatable {
        let node: RedwoodNote
        let cursor: String
    }

    public struct PageInfo: Codable, Equatable {
        let hasNextPage: Bool
        let hasPreviousPage: Bool
        let endCursor: String?
        let startCursor: String?
    }
}
