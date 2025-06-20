//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
import XCTest

class CDHLearnCourseTests: CoreTestCase {
    func testSaveSingleEnrollment() {
        let enrollment = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll_1",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course_1",
                name: "Test Course",
                account: GetHCoursesProgressionResponse.AccountModel(name: "Institution 1"),
                imageUrl: "https://example.com/image1.png",
                syllabusBody: "Syllabus 1",
                usersConnection: nil,
                modulesConnection: nil
            )
        )
        let entity = CDHLearnCourse.save(enrollment, in: databaseClient)
        XCTAssertEqual(entity.id, "course_1")
        XCTAssertEqual(entity.name, "Test Course")
        XCTAssertEqual(entity.enrollmentId, "enroll_1")
    }

    func testSaveMultipleEnrollments() {
        let enrollments = [
            GetHCoursesProgressionResponse.EnrollmentModel(
                state: "active",
                id: "enroll_1",
                course: GetHCoursesProgressionResponse.CourseModel(
                    id: "course_1",
                    name: "Course 1",
                    account: GetHCoursesProgressionResponse.AccountModel(name: "Institution 1"),
                    imageUrl: "https://example.com/image1.png",
                    syllabusBody: "Syllabus 1",
                    usersConnection: nil,
                    modulesConnection: nil
                )
            ),
            GetHCoursesProgressionResponse.EnrollmentModel(
                state: "completed",
                id: "enroll_2",
                course: GetHCoursesProgressionResponse.CourseModel(
                    id: "course_2",
                    name: "Course 2",
                    account: GetHCoursesProgressionResponse.AccountModel(name: "Institution 2"),
                    imageUrl: "https://example.com/image2.png",
                    syllabusBody: "Syllabus 2",
                    usersConnection: nil,
                    modulesConnection: nil
                )
            )
        ]
        let entities = CDHLearnCourse.save(enrollments, in: databaseClient)
        XCTAssertEqual(entities.count, 2)
        let entity1 = entities[0]
        let entity2 = entities[1]
        XCTAssertEqual(entity1.id, "course_1")
        XCTAssertEqual(entity1.name, "Course 1")
        XCTAssertEqual(entity1.enrollmentId, "enroll_1")
        XCTAssertEqual(entity2.id, "course_2")
        XCTAssertEqual(entity2.name, "Course 2")
        XCTAssertEqual(entity2.enrollmentId, "enroll_2")
    }

    func testOverwriteExistingCourse() {
        let enrollment1 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll_1",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course_1",
                name: "Original Name",
                account: GetHCoursesProgressionResponse.AccountModel(name: "Institution 1"),
                imageUrl: "https://example.com/image1.png",
                syllabusBody: "Syllabus 1",
                usersConnection: nil,
                modulesConnection: nil
            )
        )
        _ = CDHLearnCourse.save(enrollment1, in: databaseClient)
        let enrollment2 = GetHCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll_1",
            course: GetHCoursesProgressionResponse.CourseModel(
                id: "course_1",
                name: "Updated Name",
                account: GetHCoursesProgressionResponse.AccountModel(name: "Institution 1"),
                imageUrl: "https://example.com/image1.png",
                syllabusBody: "Syllabus 1",
                usersConnection: nil,
                modulesConnection: nil
            )
        )
        let updated = CDHLearnCourse.save(enrollment2, in: databaseClient)
        XCTAssertEqual(updated.id, "course_1")
        XCTAssertEqual(updated.name, "Updated Name")
        XCTAssertEqual(updated.enrollmentId, "enroll_1")
    }
}
