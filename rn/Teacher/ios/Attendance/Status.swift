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

public enum Attendance: String {
    case present, late, absent

    var label: String {
        switch self {
        case .present: return NSLocalizedString("Present", comment: "")
        case .late: return NSLocalizedString("Late", comment: "")
        case .absent: return NSLocalizedString("Absent", comment: "")
        }
    }

    var icon: UIImage {
        switch self {
        case .present: return UIImage.icon(.complete, .line)
        case .late: return UIImage.icon(.clock, .line)
        case .absent: return UIImage.icon(.trouble, .line)
        }
    }

    var tintColor: UIColor {
        switch self {
        case .present: return UIColor.named(.backgroundSuccess)
        case .late: return UIColor.named(.backgroundWarning)
        case .absent: return UIColor.named(.backgroundDanger)
        }
    }
}

public struct Stats {
    public var presences: Int
    public var tardies: Int
    public var absences: Int
    public var attendanceGrade: String
}

public struct Student {
    public var id: String
    public var name: String
    public var sortableName: String
    public var avatarURL: URL?
}

public struct Status {
    public static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "yyyy-MM-dd"
        d.locale = Locale(identifier: "en-US")
        return d
    }()

    // such IDs
    public var id: String? // null if no attendance is set
    public var studentID: String
    public var teacherID: String
    public var sectionID: String
    public var courseID: String
    
    public var student: Student
    
    public var date: Date // as yyyy-mm-dd in the current timezone
    public var attendance: Attendance?
    
    public var stats: Stats

    // seating chart data
    public var seated: Bool
    public var row: Int?
    public var col: Int?
}

import Marshal

extension Stats: Unmarshaling, Marshaling {
    public init(object: MarshaledObject) throws {
        presences       = try object <| "presences"
        tardies         = try object <| "tardies"
        absences        = try object <| "absences"
        attendanceGrade = (try object <| "attendance_grade") ?? ""
    }
    
    public func marshaled() -> [String: Any] {
        return [
            "presences"         : presences,
            "tardies"           : tardies,
            "absences"          : absences,
            "attendance_grade"  : attendanceGrade,
        ]
    }
}

extension Student: Unmarshaling, Marshaling {
    public init(object: MarshaledObject) throws {
        id              = try object.stringID("id")
        name            = try object <| "name"
        sortableName    = try object <| "sortable_name"
        
        let url: String? = try object <| "avatar_url"
        avatarURL = url.flatMap(URL.init(string:))
    }
    
    public func marshaled() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "sortable_name": sortableName,
            "avatar_url": avatarURL?.absoluteString ?? NSNull(),
        ]
    }
}

extension Status: Unmarshaling, Marshaling {
    public init(object: MarshaledObject) throws {
        
        id          = try object.stringID("id")
        studentID   = try object.stringID("student_id")
        teacherID   = try object.stringID("teacher_id")
        sectionID   = try object.stringID("section_id")
        courseID    = try object.stringID("course_id")
        attendance  = try object <| "attendance"
        stats       = try object <| "stats"
        seated      = try object <| "seated"
        row         = try object <| "row"
        col         = try object <| "col"
        student     = try object <| "student"
        
        print("STUDENT (\(studentID)): \(student.name)")
        let stringDate: String = try object <| "class_date"
        guard let d = Status.dateFormatter.date(from: stringDate) else {
            throw MarshalError.typeMismatch(expected: Date.self, actual: type(of: stringDate))
        }
        date = d
    }
    
    public func marshaled() -> [String: Any] {
        return [
            "id": id ?? NSNull(),
            "student_id": studentID,
            "teacher_id": teacherID,
            "section_id": sectionID,
            "course_id": courseID,
            "attendance": attendance?.rawValue ?? NSNull(),
            "stats": stats.marshaled(),
            "seated": seated,
            "row": row ?? NSNull(),
            "col": col ?? NSNull(),
            "student": student.marshaled(),
            "class_date": Status.dateFormatter.string(from: date),
        ]
    }
}
