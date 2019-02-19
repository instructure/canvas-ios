//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public protocol TabViewable {
    var id: String { get }
}

extension TabViewable {
    public var icon: UIImage {
        // FIXME: We will need the course-specific attendance tool id for this to work for Teachers
        // if id == attendanceToolID {
        //     return .icon(.attendance)
        // }
        if id.contains("external_tool") {
            return .icon(.lti, .solid)
        }
        switch id {
        case "announcements":  return .icon(.announcement, .line)
        case "application":    return .icon(.lti, .solid)
        case "assignments":    return .icon(.assignment, .line)
        case "attendance":     return .icon(.attendance)
        case "collaborations": return .icon(.collaborations)
        case "conferences":    return .icon(.conferences)
        case "discussions":    return .icon(.discussion, .line)
        case "files":          return .icon(.folder, .line)
        case "grades":         return .icon(.gradebook, .line)
        case "link":           return .icon(.link, .line)
        case "modules":        return .icon(.module, .line)
        case "outcomes":       return .icon(.outcomes, .line)
        case "pages":          return .icon(.document, .line)
        case "people":         return .icon(.group, .line)
        case "quizzes":        return .icon(.quiz, .line)
        case "settings":       return .icon(.settings, .line)
        case "syllabus":       return .icon(.rubric, .line)
        case "tools":          return .icon(.lti, .solid)
        case "user":           return .icon(.user, .line)
        default:               return .icon(.courses, .line)
        }
    }
}
