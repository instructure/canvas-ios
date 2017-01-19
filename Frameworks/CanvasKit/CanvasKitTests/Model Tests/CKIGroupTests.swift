//
//  CKIGroupTests.swift
//  CanvasKit
//
//  Created by Rick Roberts on 7/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
