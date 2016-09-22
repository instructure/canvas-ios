//
//  GradeTests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/11/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import CoreData
import TooLegit
import SoLazy
import SoPersistent
@testable import EnrollmentKit
import SoAutomated
import Marshal
import DoNotShipThis

class GradeTests: XCTestCase {
    let session = Session.inMemory
    var context: NSManagedObjectContext!
    var grade: Grade!

    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
            grade = Grade.build(context)
        }
    }

    func testGrade_isValid() {
        XCTAssert(grade.isValid)
    }

    func testGrade_updateValues_createsAValidGrade() {
        attempt {
            let newGrade = Grade(inContext: context)
            try newGrade.updateValues(validJSON, inContext: context)
            XCTAssert(newGrade.isValid)
        }
    }

    func testGrade_updateValues_createsCourseRelationship() {
        attempt {
            let newGrade = Grade(inContext: context)
            let course = Course.build(context, id: "1")

            try newGrade.updateValues(validJSON, inContext: context)

            XCTAssertEqual(course.id, grade.course.id)
        }
    }

    func testGrade_updateValues_setsGrades() {
        attempt {
            let newGrade = Grade(inContext: context)
            try newGrade.updateValues(validJSON, inContext: context)
            assertGradesAreSet(newGrade)
        }
    }

    func testGrade_updateValues_whenThereAreNoGrades_setsGradesToNil() {
        attempt {
            let newGrade = Grade(inContext: context)
            try newGrade.updateValues(teacherJSON, inContext: context)
            assertTeacherGradesAreNil(newGrade)
        }
    }

    // MARK: Helpers

    var validJSON: JSONObject {
        return [
            "course_id": "1",
            "grading_period_id": "1",
            "grades": [
                "current_score": 100,
                "current_grade": "A",
                "final_score": 80,
                "final_grade": "B"
            ]
        ]
    }

    var teacherJSON: JSONObject {
        return [
            "course_id": "1",
        ]
    }

    private func assertTeacherGradesAreNil(grade: Grade) {
        XCTAssertNil(grade.currentGrade, "currentGrade is nil")
        XCTAssertNil(grade.currentScore, "currentScore is nil")
        XCTAssertNil(grade.finalGrade, "finalGrade is nil")
        XCTAssertNil(grade.finalScore, "finalScore is nil")
    }

    private func assertGradesAreSet(grade: Grade) {
        XCTAssertEqual(100, grade.currentScore, "currentScore is set")
        XCTAssertEqual("A", grade.currentGrade, "currentGrade is set")
        XCTAssertEqual(80, grade.finalScore, "finalScore is set")
        XCTAssertEqual("B", grade.finalGrade, "finalGrade is set")
    }
}
