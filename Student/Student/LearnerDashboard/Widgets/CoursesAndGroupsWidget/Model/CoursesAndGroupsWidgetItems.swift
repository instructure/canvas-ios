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
import SwiftUI

struct CoursesAndGroupsWidgetCourseItem: Equatable {
    let id: String
    let title: String
    let color: Color
    let imageUrl: URL?
    let grade: String?
}

struct CoursesAndGroupsWidgetGroupItem: Equatable {
    let id: String
    let title: String
    let courseName: String
    let courseColor: Color
    let groupColor: Color
    let memberCount: Int
}

#if DEBUG

extension CoursesAndGroupsWidgetCourseItem {
    static func make(
        id: String = "",
        title: String = "",
        color: Color = .clear,
        imageUrl: URL? = nil,
        grade: String? = nil
    ) -> CoursesAndGroupsWidgetCourseItem {
        .init(
            id: id,
            title: title,
            color: color,
            imageUrl: imageUrl,
            grade: grade
        )
    }
}

extension CoursesAndGroupsWidgetGroupItem {
    static func make(
        id: String = "",
        title: String = "",
        courseName: String = "",
        courseColor: Color = .clear,
        groupColor: Color = .clear,
        memberCount: Int = 0
    ) -> CoursesAndGroupsWidgetGroupItem {
        .init(
            id: id,
            title: title,
            courseName: courseName,
            courseColor: courseColor,
            groupColor: groupColor,
            memberCount: memberCount
        )
    }
}

#endif
