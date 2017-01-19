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
@testable import SoPersistent
import TooLegit
import DoNotShipThis

class ManagedObjectCountObserverTests: XCTestCase {

    var session = Session.inMemory
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = try! session.soPersistentTestsManagedObjectContext()
    }

    func testItWorks() {
        var expectedCount: Int = 0

        let expectation = self.expectation(description: "callback called")
        let countObserver = ManagedObjectCountObserver<Panda>(predicate: NSPredicate(format: "TRUEPREDICATE"), inContext: context) { count in
            print(count)
            XCTAssertEqual(expectedCount, count, "count in callback should equal expected count")

            if count == 2 {
                expectation.fulfill()
            }
        }

        expectedCount = 1
        Panda.build(context, name: "A")

        expectedCount = 2
        Panda.build(context, name: "B")

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(2, countObserver.currentCount, "currentCount should match the amount of objects in the store")
    }
}
