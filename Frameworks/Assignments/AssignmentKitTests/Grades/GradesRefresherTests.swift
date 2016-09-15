//
//  GradesRefresherTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
@testable import AssignmentKit
import CoreData
import SoPersistent
import TooLegit

class GradesRefresherTests: XCTestCase {
    func testThatItCreatesAssignments() {
        let session = Session.nas
        let context = try! session.assignmentsManagedObjectContext()

        XCTAssertEqual(0, AssignmentGroup.count(inContext: context))

        assertDifference({ AssignmentGroup.count(inContext: context) }, 3) {
            self.refresh("assignment-grades", courseID: "1867097",inSession: session, gradingPeriodID: nil)
        }
    }

    func testThatItCreatesAssignmentGroups() {
        let session = Session.nas
        let context = try! session.assignmentsManagedObjectContext()

        assertDifference({ AssignmentGroup.count(inContext: context) }, 3) {
            self.refresh("assignment-grades", courseID: "1867097", inSession: session, gradingPeriodID: nil)
        }
    }

    func testThatItAssignsAssignmentGroup() {
        let session = Session.nas
        let context = try! session.assignmentsManagedObjectContext()
        let assignment = Assignment.build(context, id: "9599332", assignmentGroup: nil)
        try! context.save()

        self.refresh("assignment-grades", courseID: "1867097", inSession: session, gradingPeriodID: nil)

        XCTAssertEqual("Group 1", assignment.assignmentGroup?.name)
    }

    func testThatItAssignsAssignmentGroup_withGradingPeriod() {
        let session = Session.na_mgp
        let context = try! session.assignmentsManagedObjectContext()
        let assignment = Assignment.build(context, id: "1", gradingPeriodID: nil, assignmentGroup: nil)
        try! context.save()

        self.refresh("assignment-grades-mgp", courseID: "1", inSession: session, gradingPeriodID: "1")

        XCTAssertEqual("1", assignment.gradingPeriodID)
        XCTAssertEqual("Assignments", assignment.assignmentGroup?.name)
    }

    func refresh(fixture: String, courseID: String, inSession session: Session, gradingPeriodID: String?) {
        stub(session, fixture) { expectation in
            let refresher = try! Assignment.refresher(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
            refresher.refreshingCompleted.observeNext { error in
                if let error = error {
                    XCTFail("refresh failed with error \(error.localizedDescription)")
                }
                expectation.fulfill()
            }
            refresher.refresh(true)
        }
    }
}
