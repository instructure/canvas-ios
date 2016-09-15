//
//  DescribeGradingPeriod.swift
//  AssignmentKitTests
//
//  Created by Nathan Armstrong on 4/28/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import SoAutomated
import Marshal
import CoreData
import TooLegit
import DoNotShipThis

class GradingPeriodTests: XCTestCase {

    // MARK: - Model

    func testGradingPeriod_isValid() {
        attempt {
            let session = Session.inMemory
            let context = try session.enrollmentManagedObjectContext()
            let gradingPeriod = GradingPeriod.build(context)
            XCTAssert(gradingPeriod.isValid)
        }
    }

    func testGradingPeriod_updateValues() {
        attempt {

            // Given
            let json = [
                "id": "54321",
                "title": "Update Values",
                "start_date": "2014-01-07T15:04:00Z"
            ]
            let session = Session.inMemory
            let context = try session.enrollmentManagedObjectContext()
            let gradingPeriod = GradingPeriod.create(inContext: context)

            // When
            try gradingPeriod.updateValues(json, inContext: context)

            // Then
            XCTAssertEqual("54321", gradingPeriod.id)
            XCTAssertEqual("Update Values", gradingPeriod.title)
            XCTAssertNotNil(gradingPeriod.startDate)

        }
    }
}
