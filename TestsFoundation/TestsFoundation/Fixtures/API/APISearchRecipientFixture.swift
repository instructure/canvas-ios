//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core

extension APISearchRecipient {
    public static func make(
        id: ID = "1",
        name: String = "John Doe",
        full_name: String? = nil,
        pronouns: String? = nil,
        avatar_url: URL? = nil,
        type: APISearchRecipientContext? = .course,
        common_courses: [String: [String]] = [:]
    ) -> APISearchRecipient {
        return APISearchRecipient(
            id: id,
            name: name,
            full_name: full_name ?? name,
            pronouns: pronouns,
            avatar_url: APIURL(rawValue: avatar_url),
            type: type,
            common_courses: common_courses
        )
    }
}
