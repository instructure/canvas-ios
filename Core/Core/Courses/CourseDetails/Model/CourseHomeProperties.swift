//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension CourseDefaultView {

    var homeSubLabel: String? {
        switch self {
        case .assignments:
            return NSLocalizedString("Assignments", bundle: .core, comment: "")
        case .feed:
            return NSLocalizedString("Recent Activity", bundle: .core, comment: "")
        case .modules:
            return NSLocalizedString("Course Modules", bundle: .core, comment: "")
        case .syllabus:
            return NSLocalizedString("Syllabus", bundle: .core, comment: "")
        case .wiki:
            return NSLocalizedString("Front Page", bundle: .core, comment: "")
        }
    }

    func homeRoute(courseID: String) -> URL? {
        var route = "courses/\(courseID)/\(rawValue)"

        switch self {
        case .feed:
            route = "courses/\(courseID)/activity_stream"
        case .wiki:
            route = "courses/\(courseID)/pages/front_page"
        default:
            break
        }

        return URL(string: route)
    }
}
