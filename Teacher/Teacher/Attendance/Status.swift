//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import Core
import UIKit

public enum Attendance: String, Codable {
    case present, late, absent

    var label: String {
        switch self {
        case .present: return String(localized: "Present", bundle: .teacher)
        case .late: return String(localized: "Late", bundle: .teacher)
        case .absent: return String(localized: "Absent", bundle: .teacher)
        }
    }

    var icon: UIImage {
        switch self {
        case .present: return UIImage.completeLine
        case .late: return UIImage.clockLine
        case .absent: return UIImage.troubleLine
        }
    }

    var tintColor: UIColor {
        switch self {
        case .present: return UIColor.backgroundSuccess
        case .late: return UIColor.backgroundWarning
        case .absent: return UIColor.backgroundDanger
        }
    }
}

public struct Stats: Codable {
    public var presences: Int
    public var tardies: Int
    public var absences: Int
    public var attendanceGrade: String?

    enum CodingKeys: String, CodingKey {
        case presences, tardies, absences
        case attendanceGrade = "attendance_grade"
    }
}

public struct Student: Codable {
    public var id: ID
    public var name: String
    public var sortableName: String
    public var avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, name
        case sortableName = "sortable_name"
        case avatarURL = "avatar_url"
    }
}

public struct Status: Codable {
    public static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "yyyy-MM-dd"
        d.locale = Locale(identifier: "en-US")
        return d
    }()

    // such IDs
    public var id: ID? // null if no attendance is set
    public var studentID: ID
    public var teacherID: ID
    public var sectionID: ID
    public var courseID: ID

    public var student: Student?

    public var date: Date // as yyyy-mm-dd in the current timezone
    public var attendance: Attendance?

    public var stats: Stats

    // seating chart data
    public var seated: Bool
    public var row: Int?
    public var col: Int?

    enum CodingKeys: String, CodingKey {
        case id, attendance, stats, seated, row, col, student
        case studentID = "student_id"
        case teacherID = "teacher_id"
        case sectionID = "section_id"
        case courseID = "course_id"
        case date = "class_date"
    }
}
