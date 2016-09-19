//
//  GradingPeriodNetworkTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import SoAutomated
import Marshal
import TooLegit
import DoNotShipThis

class GradingPeriodNetworkTests: XCTestCase {
    func testSyncingGradingPeriods() {
        let session = Session.na_mgp
        let context = try! session.enrollmentManagedObjectContext()
        let courseID = "1"

        stub(session, "grading-periods") { expectation in
            let remote = try! GradingPeriod.getGradingPeriods(session, courseID: courseID)
            let sync = GradingPeriod.syncSignalProducer(inContext: context, fetchRemote: remote) { gradingPeriod, _ in
                gradingPeriod.courseID = courseID
            }

            sync
                .on(failed: {
                    XCTFail("failed \($0.localizedDescription)")
                })
                .startWithCompleted {
                    expectation.fulfill()
                }
        }

        let gradingPeriods: [GradingPeriod] = try! context.findAll()

        func gradingPeriodExists(id: String, title: String) -> Bool {
            return gradingPeriods.filter { $0.id == id && $0.title == title }.count == 1
        }

        XCTAssert(gradingPeriodExists("1", title: "First Period"))
        XCTAssert(gradingPeriodExists("2", title: "Second Period"))
        XCTAssert(gradingPeriodExists("3", title: "Third Period"))
    }
}
