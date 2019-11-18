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

extension APIActivity {
    public static func make(
        id: ID = "1",
        title: String = "Assignment Created: Assignment 1",
        message: String = "Assignment 1",
        html_url: URL = URL(string: "/courses/1/assignments/1")!,
        created_at: Date = Date(),
        updated_at: Date = Date(),
        type: ActivityType = .message,
        context_type: String = ContextType.course.rawValue,
        course_id: ID? = "1",
        group_id: ID? = nil
    ) -> APIActivity {
        return APIActivity(
            id: id,
            title: title,
            message: message,
            html_url: html_url,
            created_at: created_at,
            updated_at: updated_at,
            type: type,
            context_type: context_type,
            course_id: course_id,
            group_id: group_id
        )
    }
}
