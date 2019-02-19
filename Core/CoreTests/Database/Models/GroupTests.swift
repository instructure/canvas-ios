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

class GroupTests: CoreTestCase {
    func testDetailsScopeOnlyIncludesGroup() {
        let group = Group.make(["id": "1"])
        Group.make(["id": "2"])
        let list = environment.subscribe(Group.self, .details("1"))
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects, [group])
    }

    func testDashboardScopeDoesNotIncludeConcluded() {
        let notConcluded = Group.make(["id": "1", "concluded": false])
        Group.make(["id": "2", "concluded": true])
        let list = environment.subscribe(Group.self, .dashboard)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 1)
        XCTAssertEqual(objects, [notConcluded])
    }

    func testDashboardScopeOrdersByName() {
        let a = Group.make(["id": "1", "name": "a"])
        let b = Group.make(["id": "2", "name": "b"])
        let c = Group.make(["id": "3", "name": "c"])
        let list = environment.subscribe(Group.self, .dashboard)
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects?.count, 3)
        XCTAssertEqual(objects, [a, b, c])
    }

    func testColorWithNoLinkOrCourse() {
        let a = Group.make()
        _ = Color.make()

        XCTAssertEqual(a.color, .named(.ash))
    }

    func testColor() {
        let a = Group.make()
        _ = Color.make([#keyPath(Color.canvasContextID): a.canvasContextID])

        XCTAssertEqual(a.color, .red)
    }

    func testColorWithCourseID() {
        let a = Group.make(["courseID": "1"])
        _ = Color.make()

        XCTAssertEqual(a.color, .red)
    }
}
