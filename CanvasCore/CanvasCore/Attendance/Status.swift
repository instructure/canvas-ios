//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
