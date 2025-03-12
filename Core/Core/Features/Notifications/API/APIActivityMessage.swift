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

public struct APIActivityMessage: Codable {
    let id: ID
    let created_at: Date
    let body: String?
    let author_id: String
    let message: String
    let participating_user_ids: [String]
}

#if DEBUG
extension APIActivityMessage {
    public static func make (
        id: ID = "",
        created_at: Date = .now,
        body: String? = nil,
        author_id: String = "",
        message: String = "",
        participating_user_ids: [String] = []
    ) -> APIActivityMessage {
        .init(
            id: id,
            created_at: created_at,
            body: body,
            author_id: author_id,
            message: message,
            participating_user_ids: participating_user_ids
        )
    }
}
#endif
