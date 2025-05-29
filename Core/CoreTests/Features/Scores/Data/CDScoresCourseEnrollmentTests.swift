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

final class CDScoresCourseEnrollmentTests: CoreTestCase {
    func testSave() {
        let courseID = "course-123"
        let apiEnrollment = APIEnrollment.make(
            computed_current_score: 95.5,
            computed_current_grade: "A"
        )

        let savedEntity = CDScoresCourseEnrollment.save(
            courseID: courseID,
            apiEntity: apiEnrollment,
            in: databaseClient
        )

        XCTAssertEqual(savedEntity.courseID, courseID)
        XCTAssertEqual(savedEntity.grade, "A")
        XCTAssertEqual(savedEntity.score?.doubleValue, 95.5)

        let enrollments: [CDScoresCourseEnrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 1)
        XCTAssertEqual(enrollments.first?.grade, "A")
        XCTAssertEqual(enrollments.first?.score?.doubleValue, 95.5)
    }

    func testSaveWithExistingEntity() {
        let courseID = "course-123"

        let apiEnrollment1 = APIEnrollment.make(
            computed_current_score: 95.5,
            computed_current_grade: "A"
        )

        CDScoresCourseEnrollment.save(
            courseID: courseID,
            apiEntity: apiEnrollment1,
            in: databaseClient
        )

        let apiEnrollment2 = APIEnrollment.make(
            computed_current_score: 88.5,
            computed_current_grade: "B+"
        )

        let updatedEntity = CDScoresCourseEnrollment.save(
            courseID: courseID,
            apiEntity: apiEnrollment2,
            in: databaseClient
        )

        let enrollments: [CDScoresCourseEnrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 1)

        XCTAssertEqual(updatedEntity.courseID, courseID)
        XCTAssertEqual(updatedEntity.grade, "B+")
        XCTAssertEqual(updatedEntity.score?.doubleValue, 88.5)
    }

    func testSaveWithNilGrade() {
        let courseID = "course-123"
        let apiEnrollment = APIEnrollment.make(
            computed_current_score: 95.5,
            computed_current_grade: nil
        )

        let savedEntity = CDScoresCourseEnrollment.save(
            courseID: courseID,
            apiEntity: apiEnrollment,
            in: databaseClient
        )

        XCTAssertEqual(savedEntity.courseID, courseID)
        XCTAssertNil(savedEntity.grade)
        XCTAssertEqual(savedEntity.score?.doubleValue, 95.5)
    }

    func testSaveWithNilScore() {
        let courseID = "course-123"
        let apiEnrollment = APIEnrollment.make(
            user_id: "user-123",
            computed_current_score: nil,
            computed_current_grade: "A"
        )

        let savedEntity = CDScoresCourseEnrollment.save(
            courseID: courseID,
            apiEntity: apiEnrollment,
            in: databaseClient
        )

        try? databaseClient.save()

        XCTAssertEqual(savedEntity.courseID, courseID)
        XCTAssertEqual(savedEntity.grade, "A")
        XCTAssertNil(savedEntity.score)
    }

    func testUpdate() {
        let courseID = "course-123"

        let apiEnrollment1 = APIEnrollment.make(
            computed_current_score: 95.5,
            computed_current_grade: "A"
        )

        let savedEntity = CDScoresCourseEnrollment.save(
            courseID: courseID,
            apiEntity: apiEnrollment1,
            in: databaseClient
        )

        let apiEnrollment2 = APIEnrollment.make(
            computed_current_score: 88.5,
            computed_current_grade: "B+"
        )

        savedEntity.update(
            courseID: courseID,
            apiEntity: apiEnrollment2,
            in: databaseClient
        )

        let enrollments: [CDScoresCourseEnrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 1)
        XCTAssertEqual(enrollments.first?.grade, "B+")
        XCTAssertEqual(enrollments.first?.score?.doubleValue, 88.5)
    }

    func testUpdateWithNonExistingEntity() {
        let courseID = "course-123"

        let enrollment = CDScoresCourseEnrollment(context: databaseClient)
        enrollment.courseID = courseID

        let apiEnrollment = APIEnrollment.make(
            user_id: "user-123", computed_current_score: 95.5,
            computed_current_grade: "A"
        )

        enrollment.update(
            courseID: courseID,
            apiEntity: apiEnrollment,
            in: databaseClient
        )

        try? databaseClient.save()

        let enrollments: [CDScoresCourseEnrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 1)
        XCTAssertEqual(enrollments.first?.courseID, courseID)
        XCTAssertEqual(enrollments.first?.grade, "A")
        XCTAssertEqual(enrollments.first?.score?.doubleValue, 95.5)
    }
}
