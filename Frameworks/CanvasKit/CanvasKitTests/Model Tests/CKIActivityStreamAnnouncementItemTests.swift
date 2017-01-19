//
//  CKIActivityStreamAnnouncementItemTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIActivityStreamAnnouncementItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamAnnouncementItemDictionary = Helpers.loadJSONFixture("activity_stream_announcement_item") as NSDictionary?
        println("item = \(activityStreamAnnouncementItemDictionary)")
        let streamItem = CKIActivityStreamAnnouncementItem(fromJSONDictionary: activityStreamAnnouncementItemDictionary)
        
        let id: String = streamItem.announcementID
        println("id = \(id)")
        XCTAssertEqual(id, "1234", "Stream Announcement Item id was not parsed correctly")
    }
}

