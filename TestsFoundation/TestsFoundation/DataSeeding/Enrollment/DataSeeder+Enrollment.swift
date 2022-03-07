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

import Core

extension DataSeeder {

    public func enrollTeacher(_ teacher: DSUser, in course: DSCourse, state: EnrollmentState = .active) {
        self.enrollUsers([teacher], in: course, type: .TeacherEnrollment, state: state)
    }

    public func enrollTeachers(_ teachers: [DSUser], in course: DSCourse, state: EnrollmentState = .active) {
        self.enrollUsers(teachers, in: course, type: .TeacherEnrollment, state: state)
    }

    public func enrollStudent(_ student: DSUser, in course: DSCourse, state: EnrollmentState = .active) {
        self.enrollUsers([student], in: course, type: .StudentEnrollment, state: state)
    }

    public func enrollStudents(_ students: [DSUser], in course: DSCourse, state: EnrollmentState = .active) {
        self.enrollUsers(students, in: course, type: .StudentEnrollment, state: state)
    }

    public func enrollUsers(_ users: [DSUser], in course: DSCourse, type: DSEnrollmentType, state: EnrollmentState = .active) {
        for user in users {
            let requestedEnrollment = EnrollRequest.RequestedEnrollment(enrollment_state: state, user_id: user.id, type: type)
            let request = EnrollRequest(courseID: course.id, body: requestedEnrollment)
            try! makeRequest(request)
        }
    }
}
