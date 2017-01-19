//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        
        XCTAssertEqual(ContextID(id: "1", context: .group), newGroup.contextID, "contextID should match")
    }
    
    fileprivate var groupJSON: JSONObject {
        return [
            "id": "1",
            "name": "student",
        ]
    }
}
