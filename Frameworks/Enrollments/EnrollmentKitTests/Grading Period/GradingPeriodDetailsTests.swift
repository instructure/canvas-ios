//
//  GradingPeriodDetailsTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import SoPersistent
import TooLegit

class GradingPeriodDetailsTests: XCTestCase {
    func testObserverObservesChanges() {
        let session = Session.inMemory
        let context = try! session.enrollmentManagedObjectContext()
        let gradingPeriod = GradingPeriod.build(context, id: "1", courseID: "1")
        try! context.save()
        let observer = try! GradingPeriod.observer(session, id: "1", courseID: "1")
        let expectation = expectationWithDescription("it should observe changes")

        observer.signal.observeNext { change, gradingPeriod in
            if let title = gradingPeriod?.title where title == "observer" && change == .Update {
                expectation.fulfill()
            }
        }

        gradingPeriod.title = "observer"
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
