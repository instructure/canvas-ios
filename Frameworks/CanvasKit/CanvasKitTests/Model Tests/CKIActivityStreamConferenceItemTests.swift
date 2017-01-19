//
//  CKIActivityStreamConferenceItemTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIActivityStreamConferenceItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamConferenceItemDictionary = Helpers.loadJSONFixture("activity_stream_conference_item") as NSDictionary
        let streamItem = CKIActivityStreamConferenceItem(fromJSONDictionary: activityStreamConferenceItemDictionary)
        
        XCTAssertEqual(streamItem.conferenceID!, "1234", "Stream Conference Item id was not parsed correctly")
    }
}
