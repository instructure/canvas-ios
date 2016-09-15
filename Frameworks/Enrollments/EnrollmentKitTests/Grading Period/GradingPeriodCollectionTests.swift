//
//  GradingPeriodCollectionTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import TooLegit

class GradingPeriodItemTests: XCTestCase {
    func testTitle() {
        let session = Session.inMemory
        let context = try! session.enrollmentManagedObjectContext()
        var item: GradingPeriodItem

        item = .All
        XCTAssertEqual("All Grading Periods", item.title)

        item = .Some(GradingPeriod.build(context, title: "Quarter 1"))
        XCTAssertEqual("Quarter 1", item.title)
    }
}
