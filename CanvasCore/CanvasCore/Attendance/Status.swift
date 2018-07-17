//
// Copyright (C) 2017-present Instructure, Inc.
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

public enum Attendance: String {
    case present
    case absent
    case late
}

public struct Stats {
    public var presences: Int
    public var tardies: Int
    public var absences: Int
    public var attendanceGrade: String
}

public struct Student {
    public var id: Int
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
    public var id: Int? // null if no attendance is set
    public var studentID: Int
    public var teacherID: Int
    public var sectionID: Int
    public var courseID: Int
    
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
        id              = try object <| "id"
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
        
        id          = try object <| "id"
        studentID   = try object <| "student_id"
        teacherID   = try object <| "teacher_id"
        sectionID   = try object <| "section_id"
        courseID    = try object <| "course_id"
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
