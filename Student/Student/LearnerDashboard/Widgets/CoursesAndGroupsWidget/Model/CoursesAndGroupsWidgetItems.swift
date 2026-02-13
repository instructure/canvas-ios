//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation

struct CoursesAndGroupsWidgetCourseItem: Equatable {
    let id: String
    let title: String
    let color: String?
    let imageUrl: URL?
}

struct CoursesAndGroupsWidgetGroupItem: Equatable {
    let id: String
    let title: String
    let courseName: String
    let color: String?
}

#if DEBUG

extension CoursesAndGroupsWidgetCourseItem {
    static func make(
        id: String = "",
        title: String = "",
        color: String? = nil,
        imageUrl: URL? = nil
    ) -> CoursesAndGroupsWidgetCourseItem {
        .init(
            id: id,
            title: title,
            color: color,
            imageUrl: imageUrl
        )
    }
}

extension CoursesAndGroupsWidgetGroupItem {
    static func make(
        id: String = "",
        title: String = "",
        courseName: String = "",
        color: String? = nil
    ) -> CoursesAndGroupsWidgetGroupItem {
        .init(
            id: id,
            title: title,
            courseName: courseName,
            color: color
        )
    }
}

#endif
