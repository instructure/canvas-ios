//
//  ManagedObjectCountObserverTests.swift
//  SoPersistent
//
//  Created by Ben Kraus on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

        let expectation = expectationWithDescription("callback called")
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

        waitForExpectationsWithTimeout(1, handler: nil)

        XCTAssertEqual(2, countObserver.currentCount, "currentCount should match the amount of objects in the store")
    }
}
