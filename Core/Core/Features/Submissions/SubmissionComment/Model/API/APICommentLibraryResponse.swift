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

public struct APICommentLibraryResponse: PagedResponse, Equatable {
    public typealias Page = [CommentBankItem]

    struct Data: Codable, Equatable {
        let user: User
    }

    struct User: Codable, Equatable {
        let id: String
        let commentBankItems: CommentBankConnection
    }

    struct CommentBankConnection: Codable, Equatable {
        let nodes: [CommentBankItem]
        let pageInfo: APIPageInfo?
    }

    public struct CommentBankItem: Codable, Equatable {
        let id: String
        let comment: String
    }

    let data: Self.Data

    public var pageInfo: APIPageInfo? { data.user.commentBankItems.pageInfo }
    public var comments: [(id: String, comment: String)] {
        data.user.commentBankItems.nodes.map { ($0.id, $0.comment) }
    }

    public var page: [CommentBankItem] {
        data.user.commentBankItems.nodes
    }
}
