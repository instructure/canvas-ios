//
//  GroupTests.swift
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
import DoNotShipThis
import Marshal

class GroupTests: UnitTestCase {
    let session = Session.inMemory
    var context: NSManagedObjectContext!
    var group: Group!
    
    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
            group = Group.build(inSession: session)
        }
    }
    
    func testGroup_isValid() {
        XCTAssert(group.isValid)
    }
    
    // MARK: updateValues
    
    func testGroup_updateValues() {
        let newGroup = Group(inContext: context)
        
        attempt {
            try newGroup.updateValues(groupJSON, inContext: context)
        }
        
        XCTAssertEqual("1", newGroup.id, "id should match")
        XCTAssertEqual("student", newGroup.name, "name should match")
    }
    
    func testGetContextID() {
        let newGroup = Group(inContext: context)
        
        attempt {
            try newGroup.updateValues(groupJSON, inContext: context)
        }
        
        XCTAssertEqual(ContextID(id: "1", context: .Group), newGroup.contextID, "contextID should match")
    }
    
    private var groupJSON: JSONObject {
        return [
            "id": "1",
            "name": "student",
        ]
    }
}
