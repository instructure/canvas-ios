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
            return String(localized: "Assignments", bundle: .core)
        case .feed:
            return String(localized: "Recent Activity", bundle: .core)
        case .modules:
            return String(localized: "Course Modules", bundle: .core)
        case .syllabus:
            return String(localized: "Syllabus", bundle: .core)
        case .wiki:
            return String(localized: "Front Page", bundle: .core)
        }
    }

    func homeRoute(courseID: String) -> URL? {
        var route = "/courses/\(courseID)/\(rawValue)"

        switch self {
        case .feed:
            route = "/courses/\(courseID)/activity_stream"
        case .wiki:
            route = "/courses/\(courseID)/pages/front_page"
        default:
            break
        }

        return URL(string: route)
    }
}
