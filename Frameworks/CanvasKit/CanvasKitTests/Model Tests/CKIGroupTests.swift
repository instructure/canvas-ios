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

import UIKit
import XCTest

class CKIGroupTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let groupDictionary = Helpers.loadJSONFixture("group") as NSDictionary
        let group = CKIGroup(fromJSONDictionary: groupDictionary)
        
        XCTAssertEqual(group.id!, "17", "Group id was not parsed correctly")
        XCTAssertEqual(group.groupDescription!, "An awesome group about math", "Group description was not parsed correctly")
        XCTAssert(group.isPublic, "Group is public was not parsed correctly")
        XCTAssert(group.followedByUser, "Group followed by user was not parsed correctly")
        XCTAssertEqual(group.membersCount, UInt(7), "Group members count was not parsed correctly")
        XCTAssertEqual(group.joinLevel!, CKIGroupJoinLevelInvitationOnly, "Group join level was not parsed correctly")
        XCTAssertEqual(group.avatarURL!, NSURL(string: "https://instructure.com/files/avatar_image.png")!, "Group avatar url was not parsed correctly")
        XCTAssertEqual(group.courseID!, "3", "Group course id was not parsed correctly")
        XCTAssertEqual(group.path!, "/api/v1/groups/17", "Group path was not parsed correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
