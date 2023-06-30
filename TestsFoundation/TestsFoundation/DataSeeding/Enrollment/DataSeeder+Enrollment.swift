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

    @discardableResult
    public func enrollTeacher(_ teacher: DSUser, in course: DSCourse, state: EnrollmentState = .active) -> DSEnrollment {
        self.enrollUser(teacher, in: course, type: .TeacherEnrollment, state: state)
    }

    @discardableResult
    public func enrollTeachers(_ teachers: [DSUser], in course: DSCourse, state: EnrollmentState = .active) -> [DSEnrollment] {
        self.enrollUsers(teachers, in: course, type: .TeacherEnrollment, state: state)
    }

    @discardableResult
    public func enrollStudent(_ student: DSUser, in course: DSCourse, state: EnrollmentState = .active) -> DSEnrollment {
        self.enrollUser(student, in: course, type: .StudentEnrollment, state: state)
    }

    @discardableResult
    public func enrollStudents(_ students: [DSUser], in course: DSCourse, state: EnrollmentState = .active) -> [DSEnrollment] {
        self.enrollUsers(students, in: course, type: .StudentEnrollment, state: state)
    }

    @discardableResult
    public func enrollParent(_ parent: DSUser, in course: DSCourse, state: EnrollmentState = .active) -> DSEnrollment {
        self.enrollUser(parent, in: course, type: .ObserverEnrollment, state: state)
    }

    @discardableResult
    public func enrollDesigner(_ designer: DSUser, in course: DSCourse, state: EnrollmentState = .active) -> DSEnrollment {
        self.enrollUser(designer, in: course, type: .DesignerEnrollment, state: state)
    }

    @discardableResult
    public func enrollUser(_ user: DSUser, in course: DSCourse, type: DSEnrollmentType, state: EnrollmentState = .active) -> DSEnrollment {
        let requestedEnrollment = EnrollRequest.RequestedEnrollment(enrollment_state: state, user_id: user.id, type: type)
        let request = EnrollRequest(courseID: course.id, body: requestedEnrollment)
        return makeRequest(request)
    }

    @discardableResult
    public func enrollUsers(_ users: [DSUser], in course: DSCourse, type: DSEnrollmentType, state: EnrollmentState = .active) -> [DSEnrollment] {
        var enrollments = [DSEnrollment]()
        for user in users {
            let requestedEnrollment = EnrollRequest.RequestedEnrollment(enrollment_state: state, user_id: user.id, type: type)
            let request = EnrollRequest(courseID: course.id, body: requestedEnrollment)
            enrollments.append(makeRequest(request))
        }
        return enrollments
    }

    @discardableResult
    public func deleteEnrollment(_ enrollment: DSEnrollment, in course: DSCourse) -> DSEnrollment {
        let request = DeleteEnrollmentRequest(courseID: course.id, enrollmentId: enrollment.id)
        return makeRequest(request)
    }
}
