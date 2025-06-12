//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
@testable import Core

class GetActivitiesTests: CoreTestCase {

    var useCase: GetActivities!
    let studentID: String = "1"

    override func setUp() {
        super.setUp()
        useCase = GetActivities()
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-activities")
    }

    func testScope() {
        let pred = NSPredicate(format: "%K != %@ && %K != %@ && %K != %@",
                                #keyPath(Activity.typeRaw), ActivityType.conference.rawValue,
                                #keyPath(Activity.typeRaw), ActivityType.collaboration.rawValue,
                                #keyPath(Activity.typeRaw), ActivityType.assessmentRequest.rawValue)
        let contextFilter = NSPredicate(value: true)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, contextFilter])
        let order = [ NSSortDescriptor(key: #keyPath(Activity.updatedAt), ascending: false) ]
        let expected = Scope(predicate: predicate, order: order, sectionNameKeyPath: nil)
        XCTAssertEqual(useCase.scope, expected)
    }

    func testScopeForCourse() {
        let contextID = "course_1234"
        useCase = GetActivities(context: Context(.course, id: "1234"))
        let pred = NSPredicate(format: "%K != %@ && %K != %@ && %K != %@",
                               #keyPath(Activity.typeRaw), ActivityType.conference.rawValue,
                               #keyPath(Activity.typeRaw), ActivityType.collaboration.rawValue,
                               #keyPath(Activity.typeRaw), ActivityType.assessmentRequest.rawValue)
        let contextFilter = NSPredicate(format: "%K == %@", #keyPath(Activity.canvasContextIDRaw), contextID)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, contextFilter])
        let order = [ NSSortDescriptor(key: #keyPath(Activity.updatedAt), ascending: false) ]
        let expected = Scope(predicate: predicate, order: order, sectionNameKeyPath: nil)
        XCTAssertEqual(useCase.scope, expected)
    }

    func testRequest() {
        XCTAssertNotNil(useCase.request)
    }
}
