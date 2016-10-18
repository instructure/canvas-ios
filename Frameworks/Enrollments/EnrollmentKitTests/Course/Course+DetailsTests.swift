//
//  Course+DetailsTests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import CoreData
@testable import EnrollmentKit
import SoAutomated
import TooLegit
import DoNotShipThis

class CourseDetailsTests: UnitTestCase {
    let session = Session.inMemory
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }

    func testCourse_observer_observesCourse() {
        attempt {
            let observer = try Course.observer(session, courseID: "1")
            let expectation = expectationWithDescription("it observes course matching id")
            observer.signal.observeResult { result in
                switch result {
                case .Success(let value):
                    if value.0 == .Insert {
                        expectation.fulfill()
                    }
                default: break
                }
            }
            Course.build(inSession: session) { $0.id = "1" }
            waitForExpectationsWithTimeout(1, handler: nil)
        }
    }
}
