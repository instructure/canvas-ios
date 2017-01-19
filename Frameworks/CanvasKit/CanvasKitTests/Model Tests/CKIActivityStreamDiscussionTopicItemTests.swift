//
//  CKIActivityStreamDiscussionTopicItemTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIActivityStreamDiscussionTopicItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamDiscussionTopicItemDictionary = Helpers.loadJSONFixture("activity_stream_discussion_topic_item") as NSDictionary
        let streamDiscussionItem = CKIActivityStreamDiscussionTopicItem(fromJSONDictionary: activityStreamDiscussionTopicItemDictionary)
        
        XCTAssertEqual(streamDiscussionItem.totalRootDiscussionEntries, 5, "Stream Discussion Item totalRootDiscussionEntries was not parsed correctly")
        
        XCTAssert(streamDiscussionItem.requireInitialPost, "Stream Discussion Item requireInitialPost was not parsed correctly")
        
        XCTAssert(streamDiscussionItem.userHasPosted, "Stream Discussion Item userHasPosted was not parsed correctly")
    }
}
