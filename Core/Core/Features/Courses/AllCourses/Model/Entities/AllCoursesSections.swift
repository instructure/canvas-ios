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

public struct AllCoursesSections: Equatable {
    public struct Courses: Equatable {
        public let current: [AllCoursesCourseItem]
        public let past: [AllCoursesCourseItem]
        public let future: [AllCoursesCourseItem]

        var isEmpty: Bool {
            current.isEmpty && past.isEmpty && future.isEmpty
        }

        public init(
            current: [AllCoursesCourseItem] = [],
            past: [AllCoursesCourseItem] = [],
            future: [AllCoursesCourseItem] = []
        ) {
            self.current = current
            self.past = past
            self.future = future
        }
    }

    let courses: Self.Courses
    let groups: [AllCoursesGroupItem]

    var isEmpty: Bool {
        groups.isEmpty && courses.isEmpty
    }

    public init(
        courses: Self.Courses = .init(),
        groups: [AllCoursesGroupItem] = []
    ) {
        self.courses = courses
        self.groups = groups
    }
}
