//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public struct APIDiscussionParticipant: Codable, Equatable {
    public let id: ID?
    public let display_name: String?
    public let avatar_image_url: APIURL?
    public let html_url: URL?
    public let pronouns: String?
}

#if DEBUG

extension APIDiscussionParticipant {
    public static func make(
        id: ID? = "1",
        display_name: String? = "Bob",
        avatar_image_url: URL? = nil,
        html_url: URL? = URL(string: "/users/1"),
        pronouns: String? = nil
    ) -> APIDiscussionParticipant {
        return APIDiscussionParticipant(
            id: id,
            display_name: display_name,
            avatar_image_url: APIURL(rawValue: avatar_image_url),
            html_url: html_url,
            pronouns: pronouns
        )
    }

    public static func make(from user: APIUser) -> APIDiscussionParticipant {
        APIDiscussionParticipant.make(
            id: user.id,
            display_name: user.name,
            avatar_image_url: user.avatar_url?.rawValue,
            html_url: URL(string: "/users/\(user.id)"),
            pronouns: user.pronouns
        )
    }
}

#endif
