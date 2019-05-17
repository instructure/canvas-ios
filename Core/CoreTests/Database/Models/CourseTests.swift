//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class CourseTests: CoreTestCase {
    func testColor() {
        let a = Course.make()
        _ = Color.make()

        XCTAssertEqual(a.color, UIColor.red)
    }

    func testDefaultView() {
        let expected = CourseDefaultView.assignments
        let a = Course.make()
        a.defaultView = expected

        XCTAssertEqual(a.defaultView, expected)
    }

    func testEnrollmentRelationship() {
        let a = Course.make()
        let enrollment = Enrollment.make()
        a.enrollments = [enrollment]

        let pred = NSPredicate(format: "%K == %@", #keyPath(Course.id), a.id)
        let list: [Course] = environment.database.mainClient.fetch(predicate: pred, sortDescriptors: nil)
        let result = list.first
        let resultEnrollment = result?.enrollments?.first

        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.enrollments)
        XCTAssertNotNil(resultEnrollment)
        XCTAssertEqual(resultEnrollment?.canvasContextID, "course_1")
    }

    func testWidgetDisplayGradeNoEnrollments() {
        let c = Course.make()
        XCTAssertEqual(c.displayGrade, "")
    }

    func testWidgetDisplayGradeNoStudentEnrollments() {
        let c = Course.make()
        let e = Enrollment.make(["roleRaw": "TeacherEnrollment"])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "")
    }

    func testWidgetDisplayGradeScore() {
        let c = Course.make()
        let e = Enrollment.make(["computedCurrentScoreRaw": 40.05])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "40.05%")
    }

    func testWidgetDisplayGradeScoreAndGrade() {
        let c = Course.make()
        let e = Enrollment.make([
            "computedCurrentScoreRaw": 40.05,
            "computedCurrentGrade": "F-",
        ])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "40.05% - F-")
    }

    func testWidgetDisplayGradeNoScoreWithGrade() {
        let c = Course.make()
        let e = Enrollment.make([
            "computedCurrentScoreRaw": nil,
            "computedCurrentGrade": "B+",
        ])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "B+")
    }

    func testWidgetDisplayGradeNoScoreNoGrade() {
        let c = Course.make()
        let e = Enrollment.make([
            "computedCurrentScoreRaw": nil,
            "computedCurrentGrade": nil,
        ])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "N/A")
    }

    func testWidgetDisplayGradeInCurrentMGP() {
        let c = Course.make()
        let e = Enrollment.make([
            "multipleGradingPeriodsEnabled": true,
            "currentGradingPeriodID": "1",
            "currentPeriodComputedCurrentScoreRaw": 90,
            "currentPeriodComputedCurrentGrade": "A-",
        ])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "90% - A-")
    }

    func testWidgetDisplayGradeNotInCurrentMGPWithTotals() {
        let c = Course.make()
        let e = Enrollment.make([
            "multipleGradingPeriodsEnabled": true,
            "currentGradingPeriodID": nil,
            "totalsForAllGradingPeriodsOption": true,
            "computedFinalScoreRaw": 85,
            "computedFinalGrade": "B",
        ])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "85% - B")
    }

    func testWidgetDisplayGradeNotInCurrentMGPWithoutTotals() {
        let c = Course.make()
        let e = Enrollment.make([
            "multipleGradingPeriodsEnabled": true,
            "currentGradingPeriodID": nil,
            "totalsForAllGradingPeriodsOption": false,
        ])
        c.enrollments = [e]
        XCTAssertEqual(c.displayGrade, "N/A")
    }

    func testShowColorOverlay() {
        let c = Course.make(["imageDownloadURL": nil])
        XCTAssertTrue(c.showColorOverlay(hideOverlaySetting: false))

        c.imageDownloadURL = URL(string: "https://google.com")!
        XCTAssertFalse(c.showColorOverlay(hideOverlaySetting: true))
        XCTAssertTrue(c.showColorOverlay(hideOverlaySetting: false))
    }
}
