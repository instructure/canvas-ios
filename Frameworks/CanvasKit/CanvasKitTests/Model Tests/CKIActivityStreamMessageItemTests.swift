//
//  CKIActivityStreamMessageItem.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIActivityStreamMessageItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamMessageItemDictionary = Helpers.loadJSONFixture("activity_stream_message_item") as NSDictionary
        let streamItem = CKIActivityStreamMessageItem(fromJSONDictionary: activityStreamMessageItemDictionary)
        
        XCTAssertEqual(streamItem.notificationCategory!, "Assignment Graded", "Activity Stream Item notificationCategory was not parsed correctly")
    }
}
