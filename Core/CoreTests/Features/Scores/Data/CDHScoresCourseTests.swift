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

final class CDHScoresCourseTests: CoreTestCase {
    func testSave() {
        let apiCourse = APICourse.make(
            id: ID("course-123"),
            name: "Test Course",
            enrollments: [
                APIEnrollment.make(
                    user_id: "user-1",
                    computed_current_score: 95.5,
                    computed_current_grade: "A"
                )
            ],
            hide_final_grades: true,
            settings: APICourseSettings.make(
                restrict_quantitative_data: true
            )
        )

        let savedEntity = CDHScoresCourse.save(apiCourse, in: databaseClient)
        try? databaseClient.save()

        XCTAssertEqual(savedEntity.courseID, "course-123")
        XCTAssertEqual(savedEntity.enrollments.count, 1)

        let enrollments = Array(savedEntity.enrollments)
        XCTAssertTrue(enrollments.contains { $0.grade == "A" && $0.score?.doubleValue == 95.5 })

        XCTAssertNotNil(savedEntity.settings)
        XCTAssertEqual(savedEntity.settings?.restrictQuantitativeData, true)
        XCTAssertEqual(savedEntity.hideFinalGrade, true)
    }

    func testSaveWithExistingEntity() {
        let apiCourse1 = APICourse.make(
            id: ID("course-123"),
            name: "Test Course",
            enrollments: [
                APIEnrollment.make(
                    user_id: "user-123",
                    computed_current_score: 95.5,
                    computed_current_grade: "A"
                )
            ],
            settings: APICourseSettings.make(
                restrict_quantitative_data: true
            )
        )

        CDHScoresCourse.save(apiCourse1, in: databaseClient)
        try? databaseClient.save()

        let apiCourse2 = APICourse.make(
            id: ID("course-123"),
            name: "Test Course",
            enrollments: [
                APIEnrollment.make(
                    user_id: "user-123",
                    computed_current_score: 88.5,
                    computed_current_grade: "B+"
                )
            ],
            settings: APICourseSettings.make(
                restrict_quantitative_data: false
            )
        )

        let updatedEntity = CDHScoresCourse.save(apiCourse2, in: databaseClient)
        try? databaseClient.save()

        let courses: [CDHScoresCourse] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 1)

        XCTAssertEqual(updatedEntity.courseID, "course-123")
        XCTAssertEqual(updatedEntity.enrollments.count, 1)

        let enrollment = updatedEntity.enrollments.first
        XCTAssertEqual(enrollment?.grade, "B+")
        XCTAssertEqual(enrollment?.score?.doubleValue, 88.5)

        XCTAssertNotNil(updatedEntity.settings)
        XCTAssertEqual(updatedEntity.settings?.restrictQuantitativeData, false)
    }

    func testSaveWithNilEnrollment() {
        let apiCourse = APICourse.make(
            id: ID("course-123"),
            name: "Test Course",
            enrollments: nil,
            settings: APICourseSettings.make(
                restrict_quantitative_data: true
            )
        )

        let savedEntity = CDHScoresCourse.save(apiCourse, in: databaseClient)
        try? databaseClient.save()

        XCTAssertEqual(savedEntity.courseID, "course-123")
        XCTAssertEqual(savedEntity.enrollments.count, 0)

        XCTAssertNotNil(savedEntity.settings)
        XCTAssertEqual(savedEntity.settings?.restrictQuantitativeData, true)
    }

    func testSaveWithNilSettings() {
        let apiCourse = APICourse.make(
            id: ID("course-123"),
            name: "Test Course",
            enrollments: [
                APIEnrollment.make(
                    user_id: "user-123",
                    computed_current_score: 95.5,
                    computed_current_grade: "A"
                )
            ],
            settings: nil
        )

        let savedEntity = CDHScoresCourse.save(apiCourse, in: databaseClient)
        try? databaseClient.save()

        XCTAssertEqual(savedEntity.courseID, "course-123")
        XCTAssertEqual(savedEntity.enrollments.count, 1)

        XCTAssertNil(savedEntity.settings)
    }
}
