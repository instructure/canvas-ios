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

import UIKit

public protocol TabViewable {
    var id: String { get }
}

extension TabViewable {
    public var icon: UIImage {
        // FIXME: We will need the course-specific attendance tool id for this to work for Teachers
        // if id == attendanceToolID {
        //     return .attendanceLine
        // }
        if id.contains("external_tool") {
            return .ltiLine
        }
        switch id {
        case "announcements":  return .announcementLine
        case "application":    return .ltiLine
        case "assignments":    return .assignmentLine
        case "attendance":     return .attendance
        case "collaborations": return .collaborations
        case "conferences":    return .conferences
        case "discussions":    return .discussionLine
        case "files":          return .folderLine
        case "grades":         return .gradebookLine
        case "home":           return .homeLine
        case "link":           return .linkLine
        case "modules":        return .moduleLine
        case "outcomes":       return .outcomesLine
        case "pages":          return .documentLine
        case "people":         return .groupLine
        case "quizzes":        return .quizLine
        case "settings":       return .settingsLine
        case "syllabus":       return .rubricLine
        case "tools":          return .ltiLine
        case "user":           return .userLine
        default:               return .coursesLine
        }
    }
}
