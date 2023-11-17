//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct AllCoursesGroupItem: Equatable {
    public let id: String
    public let name: String

    public let courseID: String?
    public let courseName: String?
    public let courseTermName: String?
    public let courseRoles: String?

    public let concluded: Bool
    public let isFavorite: Bool

    init(
        id: String,
        name: String,
        courseID: String?,
        courseName: String?,
        courseTermName: String?,
        courseRoles: String?,
        concluded: Bool,
        isFavorite: Bool
    ) {
        self.id = id
        self.name = name
        self.courseID = courseID
        self.courseName = courseName
        self.courseTermName = courseTermName
        self.courseRoles = courseRoles
        self.concluded = concluded
        self.isFavorite = isFavorite
    }

    init(from entity: CDAllCoursesGroupItem) {
        id = entity.id
        name = entity.name
        courseID = entity.courseID
        courseName = entity.courseName
        courseTermName = entity.courseTermName
        courseRoles = entity.courseRoles
        concluded = entity.concluded
        isFavorite = entity.isFavorite
    }
}

#if DEBUG

public extension AllCoursesGroupItem {
    static func make(
        id: String = "1",
        name: String = "group-1",
        courseID: String? = "course-id",
        courseName: String? = "course-name",
        courseTermName: String? = "course-term",
        courseRoles: String? = "student",
        concluded: Bool = false,
        isFavorite: Bool = true
    ) -> AllCoursesGroupItem {
        AllCoursesGroupItem(
            id: id,
            name: name,
            courseID: courseID,
            courseName: courseName,
            courseTermName: courseTermName,
            courseRoles: courseRoles,
            concluded: concluded,
            isFavorite: isFavorite
        )
    }
}

#endif
