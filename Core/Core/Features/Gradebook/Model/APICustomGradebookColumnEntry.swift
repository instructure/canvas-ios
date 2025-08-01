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

public struct APICustomGradebookColumnEntry: Codable, Equatable {
    public let user_id: String
    public let content: String?

    public init(
        user_id: String,
        content: String?
    ) {
        self.user_id = user_id
        self.content = content
    }
}

#if DEBUG

extension APICustomGradebookColumnEntry {
    public static func make(
        user_id: String = "",
        content: String? = nil
    ) -> APICustomGradebookColumnEntry {
        .init(
            user_id: user_id,
            content: content
        )
    }
}

#endif
