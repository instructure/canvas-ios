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

public struct AllCoursesCourseItem: Equatable, Hashable {
    public let courseId: String
    public let courseCode: String
    public let enrollmentState: String
    public let isFavorite: Bool
    public let isPublished: Bool
    public let isFavoriteButtonVisible: Bool
    public let isCourseDetailsAvailable: Bool
    public let name: String
    public let roles: String
    public let termName: String?

    init(
        courseId: String,
        courseCode: String,
        enrollmentState: String,
        isFavorite: Bool,
        isPublished: Bool,
        isFavoriteButtonVisible: Bool,
        isCourseDetailsAvailable: Bool,
        name: String,
        roles: String,
        termName: String?
    ) {
        self.courseId = courseId
        self.courseCode = courseCode
        self.enrollmentState = enrollmentState
        self.isFavorite = isFavorite
        self.isPublished = isPublished
        self.isFavoriteButtonVisible = isFavoriteButtonVisible
        self.isCourseDetailsAvailable = isCourseDetailsAvailable
        self.name = name
        self.roles = roles
        self.termName = termName
    }

    init(from entity: CDAllCoursesCourseItem) {
        courseId = entity.courseId
        courseCode = entity.courseCode
        enrollmentState = entity.enrollmentState
        isFavorite = entity.isFavorite
        isPublished = entity.isPublished
        isFavoriteButtonVisible = entity.isFavoriteButtonVisible
        isCourseDetailsAvailable = entity.isCourseDetailsAvailable
        name = entity.name
        roles = entity.roles
        termName = entity.termName
    }
}

#if DEBUG

public extension AllCoursesCourseItem {
    static func make(
        courseId: String = "1",
        courseCode: String = "1",
        enrollmentState: String = "active",
        isFavorite: Bool = true,
        isPublished: Bool = true,
        isFavoriteButtonVisible: Bool = true,
        isCourseDetailsAvailable: Bool = true,
        name: String = "course-1",
        roles: String = "",
        termName: String? = nil
    ) -> AllCoursesCourseItem {
        AllCoursesCourseItem(
            courseId: courseId,
            courseCode: courseCode,
            enrollmentState: enrollmentState,
            isFavorite: isFavorite,
            isPublished: isPublished,
            isFavoriteButtonVisible: isFavoriteButtonVisible,
            isCourseDetailsAvailable: isCourseDetailsAvailable,
            name: name,
            roles: roles,
            termName: termName
        )
    }
}

#endif
