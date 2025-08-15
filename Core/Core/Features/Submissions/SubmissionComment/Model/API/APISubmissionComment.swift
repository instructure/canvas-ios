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

import Foundation

// https://canvas.instructure.com/doc/api/submissions.html#SubmissionComment
public struct APISubmissionComment: Codable, Equatable {
    let id: String
    let attempt: Int?
    let author_id: ID?
    let author_name: String
    let author: APISubmissionComment.Author
    let comment: String
    let created_at: Date
    let edited_at: Date?
    let media_comment: APISubmissionComment.Media?
    let attachments: [APIFile]?
}

extension APISubmissionComment {
    public struct Author: Codable, Equatable {
        let id: ID?
        let display_name: String?
        let avatar_image_url: APIURL?
        let html_url: URL?
        let pronouns: String?
    }

    public struct Media: Codable, Equatable {
        let url: URL
        let media_id: String
        let media_type: MediaCommentType
        let display_name: String?
    }
}

#if DEBUG

extension APISubmissionComment {
    public static func make(
        id: String = "1",
        attempt: Int? = 0,
        author_id: ID? = "1",
        author_name: String = "Steve",
        author: APISubmissionComment.Author = .make(),
        comment: String = "comment",
        created_at: Date = Date(fromISOString: "2019-03-13T21:00:36Z")!,
        edited_at: Date? = nil,
        media_comment: APISubmissionComment.Media? = nil,
        attachments: [APIFile]? = nil
    ) -> APISubmissionComment {
        return APISubmissionComment(
            id: id,
            attempt: attempt,
            author_id: author_id,
            author_name: author_name,
            author: author,
            comment: comment,
            created_at: created_at,
            edited_at: edited_at,
            media_comment: media_comment,
            attachments: attachments
        )
    }
}

extension APISubmissionComment.Author {
    public static func make(
        id: ID? = "1",
        display_name: String? = "Steve",
        avatar_image_url: APIURL? = nil,
        html_url: URL? = URL(string: "/users/1"),
        pronouns: String? = nil
    ) -> Self {
        .init(
            id: id,
            display_name: display_name,
            avatar_image_url: avatar_image_url,
            html_url: html_url,
            pronouns: pronouns
        )
    }

    public static func make(from user: APIUser) -> Self {
        .init(
            id: user.id,
            display_name: user.name,
            avatar_image_url: user.avatar_url,
            html_url: URL(string: "/users/\(user.id)"),
            pronouns: user.pronouns
        )
    }
}

extension APISubmissionComment.Media {
    public static func make(
        url: URL = URL(string: "data:video/x-m4v,")!,
        media_id: String = "m1",
        media_type: MediaCommentType = .video,
        display_name: String? = nil
    ) -> Self {
        .init(
            url: url,
            media_id: media_id,
            media_type: media_type,
            display_name: display_name
        )
    }
}

#endif
