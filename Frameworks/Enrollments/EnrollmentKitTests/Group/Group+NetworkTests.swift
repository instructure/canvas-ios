//
//  Group+NetworkTests.swift
//  Enrollments
//
//  Created by Egan Anderson on 6/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import CoreData
@testable import EnrollmentKit
import SoAutomated
import TooLegit
import Marshal

class GroupNetworkTests: UnitTestCase {
    var session = Session.art
    
    // MARK: getAllCourses
    
    func testGroup_getAllGroups() {
        var response: [JSONObject]?
        stub(session, "get-all-groups") { expectation in
            try Group.getAllGroups(session).startWithCompletedExpectation(expectation) { value in
                response = value
                XCTAssertEqual(2, response!.count, "number of groups should match")
            }
        }
    }
}