//
//  CKIActivityStreamConversationItem.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIActivityStreamConversationItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamConversationItemDictionary = Helpers.loadJSONFixture("activity_stream_conversation_item") as NSDictionary
        let streamConversationItem = CKIActivityStreamConversationItem(fromJSONDictionary: activityStreamConversationItemDictionary)
        
        XCTAssert(streamConversationItem.isPrivate, "Stream Conversation Item isPrivate was not parsed correctly")
        
        XCTAssertEqual(streamConversationItem.participantCount, UInt(3), "Stream Discussion Item participantCount was not parsed correctly")
        
        XCTAssertEqual(streamConversationItem.conversationID!, "1234", "Stream Discussion Item conversationID was not parsed correctly")
    }
}
