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

// https://canvas.instructure.com/doc/api/sections.html#method.sections.index
public struct GetCourseSectionsRequest: APIRequestable {
    public typealias Response = [APICourseSection]

    let courseID: String
    let perPage: Int

    public var path: String {
        return "\(ContextModel(.course, id: courseID).pathComponent)/sections"
    }

    public var query: [APIQueryItem] {
        return [ APIQueryItem.value("per_page", "\(perPage)") ]
    }
}
