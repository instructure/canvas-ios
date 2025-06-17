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

final class HScoresCourseTests: CoreTestCase {
    func testInitWithParameters() {
        let enrollments = [
            HScoresCourseEnrollment(
                courseID: "course-123",
                score: 95.5,
                grade: "A"
            )
        ]

        let settings = HScoresCourseSettings(restrictQuantitativeData: true)

        let course = HScoresCourse(
            courseID: "course-123",
            enrollments: enrollments,
            hideFinalGrade: true,
            settings: settings
        )

        XCTAssertEqual(course.courseID, "course-123")
        XCTAssertEqual(course.enrollments.count, 1)
        XCTAssertEqual(course.enrollments[0].score, 95.5)
        XCTAssertEqual(course.enrollments[0].grade, "A")
        XCTAssertEqual(course.settings.restrictQuantitativeData, true)
        XCTAssertEqual(course.hideFinalGrade, true)
    }

    func testInitFromEntity() {
        let courseEntity = CDHScoresCourse(context: databaseClient)
        courseEntity.courseID = "course-123"
        courseEntity.hideFinalGrade = false

        let enrollmentEntity = CDHScoresCourseEnrollment(context: databaseClient)
        enrollmentEntity.courseID = "course-123"
        enrollmentEntity.grade = "A"
        enrollmentEntity.score = NSNumber(value: 95.5)

        let settingsEntity = CDHScoresCourseSettings(context: databaseClient)
        settingsEntity.restrictQuantitativeData = true

        courseEntity.enrollments = [enrollmentEntity]
        courseEntity.settings = settingsEntity
        settingsEntity.course = courseEntity

        let course = HScoresCourse(from: courseEntity)

        XCTAssertEqual(course.courseID, "course-123")
        XCTAssertEqual(course.enrollments.count, 1)
        XCTAssertEqual(course.enrollments[0].score, 95.5)
        XCTAssertEqual(course.enrollments[0].grade, "A")
        XCTAssertEqual(course.settings.restrictQuantitativeData, true)
        XCTAssertEqual(course.hideFinalGrade, false)
    }

    func testInitFromEntityWithNoSettings() {
        let courseEntity = CDHScoresCourse(context: databaseClient)
        courseEntity.courseID = "course-123"
        courseEntity.settings = nil

        let enrollmentEntity = CDHScoresCourseEnrollment(context: databaseClient)
        enrollmentEntity.courseID = "course-123"
        enrollmentEntity.grade = "A"
        enrollmentEntity.score = NSNumber(value: 95.5)

        courseEntity.enrollments = [enrollmentEntity]

        let course = HScoresCourse(from: courseEntity)

        XCTAssertEqual(course.courseID, "course-123")
        XCTAssertEqual(course.enrollments.count, 1)

        XCTAssertEqual(course.settings.restrictQuantitativeData, false)
    }
}

final class ScoresCourseEnrollmentTests: CoreTestCase {
    func testInitWithParameters() {
        let enrollment = HScoresCourseEnrollment(
            courseID: "course-123",
            score: 95.5,
            grade: "A"
        )

        XCTAssertEqual(enrollment.courseID, "course-123")
        XCTAssertEqual(enrollment.score, 95.5)
        XCTAssertEqual(enrollment.grade, "A")
    }

    func testInitFromEntity() {
        let entity = CDHScoresCourseEnrollment(context: databaseClient)
        entity.courseID = "course-123"
        entity.grade = "A"
        entity.score = NSNumber(value: 95.5)

        let enrollment = HScoresCourseEnrollment(from: entity)

        XCTAssertEqual(enrollment.courseID, "course-123")
        XCTAssertEqual(enrollment.score, 95.5)
        XCTAssertEqual(enrollment.grade, "A")
    }

    func testInitFromEntityWithNilValues() {
        let entity = CDHScoresCourseEnrollment(context: databaseClient)
        entity.courseID = "course-123"
        entity.grade = nil
        entity.score = nil

        let enrollment = HScoresCourseEnrollment(from: entity)

        XCTAssertEqual(enrollment.courseID, "course-123")
        XCTAssertNil(enrollment.score)
        XCTAssertNil(enrollment.grade)
    }
}

final class ScoresCourseSettingsTests: CoreTestCase {
    func testInitWithParameters() {
        let settings = HScoresCourseSettings(restrictQuantitativeData: true)
        XCTAssertEqual(settings.restrictQuantitativeData, true)
    }

    func testInitFromEntity() {
        let entity = CDHScoresCourseSettings(context: databaseClient)
        entity.restrictQuantitativeData = true

        let settings = HScoresCourseSettings(from: entity)

        XCTAssertEqual(settings.restrictQuantitativeData, true)
    }
}
