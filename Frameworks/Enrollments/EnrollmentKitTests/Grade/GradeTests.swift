
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
            grade = Grade.build(inSession: session)
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
            let course = Course.build(inSession: session) { $0.id = "1" }

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
