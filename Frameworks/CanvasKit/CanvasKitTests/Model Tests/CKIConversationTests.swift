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

class CKIConversationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let conversationDictionary = Helpers.loadJSONFixture("conversation") as NSDictionary
        let conversation = CKIConversation(fromJSONDictionary: conversationDictionary)
        
        XCTAssertEqual(conversation.id!, "2", "conversation id was not parsed correctly")
        XCTAssertEqual(conversation.subject!, "conversations api example", "conversation subject was not parsed correctly")
        XCTAssertEqual(conversation.workflowState, CKIConversationWorkflowState.Unread, "conversation workflowState was not parsed correctly")
        XCTAssertEqual(conversation.lastMessage!, "sure thing, here's the file", "conversation lastMessage was not parsed correctly")
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2011-09-02T12:00:00-06:00")
        XCTAssertEqual(conversation.lastMessageAt!, date, "conversation lastMessageAt was not parsed correctly")
        XCTAssertEqual(conversation.messageCount, UInt(2), "conversation messageCount was not parsed correctly")
        XCTAssert(conversation.isSubscribed, "conversation isSubscribed was not parsed correctly")
        XCTAssert(conversation.isPrivate, "conversation isPrivate was not parsed correctly")
        XCTAssertEqual(conversation.properties.count, 3, "conversation properties was not parsed correctly")
        XCTAssert(conversation.isLastAuthor, "conversation isLastAuthor was not parsed correctly")
        XCTAssert(conversation.hasAttachments, "conversation hasAttachments was not parsed correctly")
        XCTAssert(conversation.containsMediaObjects, "conversation containsMediaObjects was not parsed correctly")
        XCTAssertEqual(conversation.audienceContexts.count, 2, "conversation audienceContexts was not parsed correctly")

        var url = NSURL(string:"https://canvas.instructure.com/images/messages/avatar-50.png")
        XCTAssertEqual(conversation.avatarURL!, url!, "conversation avatarURL was not parsed correctly")
        XCTAssertEqual(conversation.participants.count, 3, "conversation participants was not parsed correctly")
        XCTAssertEqual(conversation.messages.count, 2, "conversation messages was not parsed correctly")
        XCTAssertEqual(conversation.path!, "/api/v1/conversations/2", "conversation path was not parsed correctly")
        
        var secondConversation = CKIConversation()
        secondConversation.mergeNewMessageFromConversation(conversation)
        XCTAssertNotNil(secondConversation.lastMessage, "conversation mergeNewMessageFromCOnversation did not work correctly")
        XCTAssertNotNil(secondConversation.messageCount, "conversation mergeNewMessageFromCOnversation did not work correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
