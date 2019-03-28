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
    func testDetailsScopeOnlyIncludesCourse() {
        let course = Course.make(["id": "1"])
        let other = Course.make(["id": "2"])
        let list = environment.subscribe(Course.self, .details("1"))
        list.performFetch()
        let objects = list.fetchedObjects
        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects?.contains(course), true)
        XCTAssertEqual(objects?.contains(other), false)
    }

    func testAllScope() {
        let one = Course.make(["id": "1"])
        let two = Course.make(["id": "2"])
        let list = environment.subscribe(Course.self, .all)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 2)
        XCTAssertEqual(objects?.contains(one), true)
        XCTAssertEqual(objects?.contains(two), true)
    }

    func testFavoritesScopeOnlyIncludesFavorites() {
        let favorite = Course.make(["id": "1", "isFavorite": true])
        let nonFavorite = Course.make(["id": "1", "isFavorite": false])
        let list = environment.subscribe(Course.self, .favorites)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects?.first, favorite)
        XCTAssertEqual(objects?.contains(nonFavorite), false)
    }

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

}
