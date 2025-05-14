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

import Foundation

extension DataSeeder {
    public func createCourse(
        name: String = "DS iOS Course \(Int(Date().timeIntervalSince1970))",
        syllabus_body: String? = nil,
        start_at: Date? = nil,
        end_at: Date? = nil,
        default_view: DSDefaultView? = nil,
        enrollmentTerm: DSEnrollmentTerm? = nil,
        hide_final_grades: Bool? = nil
    ) -> DSCourse {
        let requestedBody = CreateDSCourseRequest.Body(
            course: .init(
                name: name,
                syllabus_body: syllabus_body,
                start_at: start_at,
                end_at: end_at,
                default_view: default_view,
                enrollment_term_id: enrollmentTerm?.id ?? nil,
                hide_final_grades: hide_final_grades
            )
        )
        let request = CreateDSCourseRequest(body: requestedBody)
        return makeRequest(request)
    }

    public func createCourses(count: Int) -> [DSCourse] {
        var courses = [DSCourse]()
        for _ in 0..<count {
            let course = createCourse()
            courses.append(course)
            sleep(1) // To avoid courses having the same title
        }
        return courses
    }

    public func createK5Course(name: String = "DataSeed iOS K5 \(Int(Date().timeIntervalSince1970))") -> DSCourse {
        let requestedBody = CreateDSCourseRequest.Body(course: .init(name: name))
        let request = CreateDSCourseRequest(body: requestedBody, isK5: true)
        var course = makeRequest(request)
        updateCourseToHomeroomCourse(course: course)
        course.homeroom_course = true
        return course
    }

    public func updateCourseWithGradingScheme(courseId: String, gradingStandardId: Int) {
        let requestedBody = UpdateDSCourseRequest.Body(course: .init(grading_standard_id: gradingStandardId))
        let request = UpdateDSCourseRequest(body: requestedBody, courseId: courseId)
        makeRequest(request)
    }

    public func updateCourseWithDefaultView(course: DSCourse, default_view: DSDefaultView) {
        let requestedBody = UpdateDSCourseRequest.Body(course: .init(default_view: default_view))
        let request = UpdateDSCourseRequest(body: requestedBody, courseId: course.id)
        makeRequest(request)
    }

    public func updateCourseToHomeroomCourse(course: DSCourse) {
        let requestedBody = UpdateDSCourseRequest.Body(course: .init(homeroom_course: true))
        let request = UpdateDSCourseRequest(body: requestedBody, courseId: course.id)
        makeRequest(request)
    }

    public func updateCourseSettings(course: DSCourse, restrictQuantitativeData: Bool? = nil, syllabus_course_summary: Bool? = nil) {
        let requestBody = UpdateDSCourseSettingsRequest.Body(
                restrict_quantitative_data: restrictQuantitativeData,
                syllabus_course_summary: syllabus_course_summary)
        let request = UpdateDSCourseSettingsRequest(body: requestBody, course: course)
        makeRequest(request)
    }
}
