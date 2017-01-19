//
//  CKIAssignmentGroupTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIAssignmentGroupTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let assignmentGroupDictionary = Helpers.loadJSONFixture("assignment_group_with_assignments") as NSDictionary?
        let assignmentGroup = CKIAssignmentGroup(fromJSONDictionary: assignmentGroupDictionary)
        
        XCTAssertEqual(assignmentGroup.id!, "1030331", "Assignment Group id did not parse correctly")
        XCTAssertEqual(assignmentGroup.name!, "flashcards", "Assignment Group name did not parse correctly")
        XCTAssertEqual(assignmentGroup.position, 1, "Assignment Group position did not parse correctly")
        XCTAssertEqual(assignmentGroup.weight, 25, "Assignment Group weight did not parse correctly")
        XCTAssertEqual(assignmentGroup.assignments.count, 5, "Assignment Group assignments did not parse correctly")
        XCTAssertEqual(assignmentGroup.rules.count, 0, "Assignment Group rules did not parse correctly")
    }
}
