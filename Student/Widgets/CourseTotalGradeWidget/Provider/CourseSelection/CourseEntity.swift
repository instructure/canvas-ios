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

import AppIntents
import SwiftUI

struct CourseEntity: AppEntity {
    struct CourseID {
        let courseId: String, domain: String
    }

    var id: CourseID { CourseID(courseId: courseId, domain: domain) }
    let courseId: String
    let courseName: String
    let domain: String
    var isKnown: Bool = true

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Course"
    static var defaultQuery = CourseQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(courseName)")
    }
}

extension CourseEntity.CourseID: Hashable, EntityIdentifierConvertible {

    var entityIdentifierString: String {
        [courseId, domain].joined(separator: "|")
    }

    static func entityIdentifier(for entityIdentifierString: String) -> CourseEntity.ID? {
        let components = entityIdentifierString.components(separatedBy: "|")
        guard components.count == 2 else { return nil }
        return Self(courseId: components[0], domain: components[1])
    }
}
