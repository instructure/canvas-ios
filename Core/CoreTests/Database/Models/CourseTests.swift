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
}
