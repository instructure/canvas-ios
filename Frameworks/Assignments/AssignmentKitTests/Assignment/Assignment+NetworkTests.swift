//
//  AssignmentNetworkTests.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import ReactiveCocoa
import Marshal
@testable import AssignmentKit

class AssignmentNetworkTests: UnitTestCase {
    
    func testGetAssignment() {
        
        let session = Session.ns
        let courseID = "1140383"
        let assignmentID = "9091235"
        var response: JSONObject?
        
        attempt {
            stub(session, "get-assignment") { expectation in
                try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).startWithCompletedExpectation(expectation) {
                    response = $0
                }
            }
        }
        
        XCTAssertNotNil(response)
        
        guard let json = response else {
            XCTFail("expected response to not be nil")
            return
        }
        
        XCTAssert(json.keys.contains("id"))
        XCTAssert(json.keys.contains("course_id"))
        XCTAssert(json.keys.contains("name"))
        XCTAssert(json.keys.contains("description"))
        XCTAssert(json.keys.contains("html_url"))
        XCTAssert(json.keys.contains("submission_types"))
        XCTAssert(json.keys.contains("points_possible"))
        XCTAssert(json.keys.contains("grading_type"))
        XCTAssert(json.keys.contains("use_rubric_for_grading"))
        XCTAssert(json.keys.contains("assignment_group_id"))
        XCTAssert(json.keys.contains("submission"))
        XCTAssert(json.keys.contains("published"))
        XCTAssert(json.keys.contains("locked_for_user"))
        XCTAssert(json.keys.contains("rubric"))
    }
    
    func testGetAssignments() {
        let session = Session.ns
        let courseID = "1140383"
        var response: [JSONObject]?
        
        attempt {
            stub(session, "get-assignments") { expectation in
                try Assignment.getAssignments(session, courseID: courseID).startWithCompletedExpectation(expectation) {
                    response = $0
                }
            }
        }
        
        XCTAssertNotNil(response)

        guard let json = response, assignment = json.first where json.count == 48 else {
            XCTFail("expected response to not be nil")
            return
        }
        
        XCTAssert(assignment.count > 0)
        XCTAssert(assignment.keys.contains("id"))
        XCTAssert(assignment.keys.contains("course_id"))
        XCTAssert(assignment.keys.contains("name"))
        XCTAssert(assignment.keys.contains("description"))
        XCTAssert(assignment.keys.contains("html_url"))
        XCTAssert(assignment.keys.contains("submission_types"))
        XCTAssert(assignment.keys.contains("points_possible"))
        XCTAssert(assignment.keys.contains("grading_type"))
        XCTAssert(assignment.keys.contains("use_rubric_for_grading"))
        XCTAssert(assignment.keys.contains("assignment_group_id"))
        XCTAssert(assignment.keys.contains("submission"))
        XCTAssert(assignment.keys.contains("published"))
        XCTAssert(assignment.keys.contains("locked_for_user"))
        XCTAssert(assignment.keys.contains("rubric"))
    }
}
