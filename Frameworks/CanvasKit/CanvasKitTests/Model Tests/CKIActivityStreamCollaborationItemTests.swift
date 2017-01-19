//
//  CKIActivityStreamCollaborationItemTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIActivityStreamCollaborationItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamCollaborationItemDictionary = Helpers.loadJSONFixture("activity_stream_collaboration_item") as NSDictionary
        let streamItem = CKIActivityStreamCollaborationItem(fromJSONDictionary: activityStreamCollaborationItemDictionary)
        
        XCTAssertEqual(streamItem.collaborationID!, "1234", "Stream Collaboration Item id was not parsed correctly")
    }
}
