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

// https://canvas.instructure.com/doc/api/sections.html#Section
public struct APICourseSection: Codable, Equatable {
    let id: ID
    let name: String
    // let sis_section_id: String?
    // let integration_id: String?
    // let sis_import_id: String?
    let course_id: ID
    // let sis_course_id: String?
    let start_at: Date?
    let end_at: Date?
    // let restrict_enrollments_to_section_dates: Bool?
    // let nonxlist_course_id: String?
    let total_students: Int?
}

#if DEBUG
extension APICourseSection {
    public static func make(
        id: ID = "1",
        name: String = "section",
        course_id: ID = "1",
        start_at: Date? = nil,
        end_at: Date? = nil,
        total_students: Int? = nil
    ) -> APICourseSection {
        return APICourseSection(
            id: id,
            name: name,
            course_id: course_id,
            start_at: start_at,
            end_at: end_at,
            total_students: total_students
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/sections.html#method.sections.index
public struct GetCourseSectionsRequest: APIRequestable {
    public typealias Response = [APICourseSection]

    public enum Include: String {
        case total_students
    }

    let courseID: String
    let include: [Include]
    let perPage: Int

    init(courseID: String, include: [Include] = [], perPage: Int = 100) {
        self.courseID = courseID
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        return "\(Context(.course, id: courseID).pathComponent)/sections"
    }

    public var query: [APIQueryItem] {
        [ .perPage(perPage), .include(include.map { $0.rawValue }) ]
    }
}
