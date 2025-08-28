//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
@testable import Core
@testable import Teacher

extension Status {
    static func make(
        id: ID? = "1",
        studentID: ID = "1",
        teacherID: ID = "2",
        sectionID: ID = "1",
        courseID: ID = "1",
        student: Student? = .make(),
        date: Date = Date(),
        attendance: Attendance? = nil,
        stats: Stats = .make(),
        seated: Bool = false,
        row: Int? = nil,
        col: Int? = nil
    ) -> Status {
        return Status(
            id: id,
            studentID: studentID,
            teacherID: teacherID,
            sectionID: sectionID,
            courseID: courseID,
            student: student,
            date: date,
            attendance: attendance,
            stats: stats,
            seated: seated,
            row: row,
            col: col
        )
    }
}

extension Student {
    static func make(
        id: ID = "1",
        name: String = "Bob",
        sortableName: String = "Bob",
        avatarURL: URL? = nil
    ) -> Student {
        return Student(
            id: id,
            name: name,
            sortableName: sortableName,
            avatarURL: avatarURL
        )
    }
}

extension Stats {
    static func make(
        presences: Int = 0,
        tardies: Int = 0,
        absences: Int = 0,
        attendanceGrade: String = ""
    ) -> Stats {
        return Stats(
            presences: presences,
            tardies: tardies,
            absences: absences,
            attendanceGrade: attendanceGrade
        )
    }
}

class StatusTests: TeacherTestCase {
    func testAttendanceProperties() {
        XCTAssertEqual(Attendance.present.label, "Present")
        XCTAssertEqual(Attendance.present.icon, UIImage.completeLine)
        XCTAssertEqual(Attendance.present.tintColor, UIColor.backgroundSuccess)
        XCTAssertEqual(Attendance.late.label, "Late")
        XCTAssertEqual(Attendance.late.icon, UIImage.clockLine)
        XCTAssertEqual(Attendance.late.tintColor, UIColor.backgroundWarning)
        XCTAssertEqual(Attendance.absent.label, "Absent")
        XCTAssertEqual(Attendance.absent.icon, UIImage.troubleLine)
        XCTAssertEqual(Attendance.absent.tintColor, UIColor.backgroundDanger)
    }

    func testStatusDateFormatter() {
        let date = DateComponents(calendar: Calendar.current, timeZone: .current, year: 2019, month: 10, day: 31).date!
        XCTAssertEqual(Status.dateFormatter.string(from: date), "2019-10-31")
        XCTAssertEqual(Status.dateFormatter.date(from: "2019-10-31"), date)
    }
}
