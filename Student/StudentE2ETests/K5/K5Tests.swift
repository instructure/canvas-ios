//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import TestsFoundation

class K5Tests: K5E2ETestCase {
    func testK5Course() {
        // MARK: Seed the usual stuff with a K5 course
        let student = seeder.createK5User()
        let courseHomeroom = seeder.createK5Course()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: courseHomeroom)
        seeder.enrollStudent(student, in: course)
        let accountNotification = AnnouncementsHelper.postAccountNotification(isK5: true)
        let assignment = AssignmentsHelper.createAssignment(course: course, dueDate: CalendarHelper.formatDate())

        // MARK: Get first user logged in
        logInDSUser(student)
        print("ASD")
    }
}
