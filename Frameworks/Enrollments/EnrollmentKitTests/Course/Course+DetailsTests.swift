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
            let course = Course.build(context, id: "1")
            let expectation = expectationWithDescription("it observes course matching id")

            let observer = try Course.observer(session, courseID: "1")
            observer.observe(course, change: .Insert, withExpectation: expectation)

            waitForExpectationsWithTimeout(1, handler: nil)
        }
    }
}
