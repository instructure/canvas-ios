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

import Foundation

enum CollectionItemFilterType: String, CaseIterable {
    case all = "all"
    case assignment = "ASSIGNMENT"
    case course = "COURSE"
    case externalLink = "EXTERNAL_URL"
    case externalTool = "EXTERNAL_TOOL"
    case file = "FILE"
    case page = "PAGE"
    case assessment = "QUIZ"

    var name: String {
        switch self {
        case .all: String(localized: "All")
        case .assignment: String(localized: "Assignments")
        case .course: String(localized: "Courses")
        case .externalLink: String(localized: "External Links")
        case .externalTool: String(localized: "External Tools")
        case .file: String(localized: "Files")
        case .page: String(localized: "Pages")
        case .assessment: String(localized: "Assessments")
        }
    }
}
