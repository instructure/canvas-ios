//
//  CKIConversationNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIConversationNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchConversationsInScope() {
        let client = MockCKIClient()
        
        client.fetchConversationsInScope(CKIConversationScope.Starred)
        XCTAssertEqual(client.capturedPath!, "/api/v1/conversations", "CKIConversation returned API path for testFetchConversationsInScope was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIConversation API Interaction Method was incorrect")
    }

    func testRefreshConversation() {
        let client = MockCKIClient()
        let conversationDictionary = Helpers.loadJSONFixture("conversation") as NSDictionary
        let conversation = CKIConversation(fromJSONDictionary: conversationDictionary)
        
        client.refreshConversation(conversation)
        XCTAssertEqual(client.capturedPath!, "/api/v1/conversations/2", "CKIConversation returned API path for testRefreshConversation was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIConversation API Interaction Method was incorrect")
    }
    
    func testCreateConversationWithRecipientIDsMessage() {
        let client = MockCKIClient()
        let conversationDictionary = Helpers.loadJSONFixture("conversation") as NSDictionary
        let conversation = CKIConversation(fromJSONDictionary: conversationDictionary)

        client.createConversationWithRecipientIDs(["1", "2", "3"], message: "Bonjour!")
        XCTAssertEqual(client.capturedPath!, "/api/v1/conversations", "CKIConversation returned API path for testCreateConversationWithRecipientIDsMessageAttachmentIDs was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIConversation API Interaction Method was incorrect")
    }

    func testCreateConversationWithRecipientIDsMessageAttachmentIDs() {
        let client = MockCKIClient()
        let conversationDictionary = Helpers.loadJSONFixture("conversation") as NSDictionary
        let conversation = CKIConversation(fromJSONDictionary: conversationDictionary)
        
        client.createConversationWithRecipientIDs(["1", "2", "3"], message: "Bonjour!", attachmentIDs:["1"])
        XCTAssertEqual(client.capturedPath!, "/api/v1/conversations", "CKIConversation returned API path for testCreateConversationWithRecipientIDsMessageAttachmentIDs was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIConversation API Interaction Method was incorrect")
    }

    func testCreateMessageInConversationWithAttachmentIDs() {
        let client = MockCKIClient()
        let conversationDictionary = Helpers.loadJSONFixture("conversation") as NSDictionary
        let conversation = CKIConversation(fromJSONDictionary: conversationDictionary)
        
        client.createMessage("Bonjour!", inConversation: conversation, withAttachmentIDs: ["1", "2", "3"])
        XCTAssertEqual(client.capturedPath!, "/api/v1/conversations/2/add_message", "CKIConversation returned API path for testCreateMessageInConversationWithAttachmentIDs was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIConversation API Interaction Method was incorrect")
    }
    
    func testAddNewRecipientsIDsToConversation() {
        let client = MockCKIClient()
        let conversationDictionary = Helpers.loadJSONFixture("conversation") as NSDictionary
        let conversation = CKIConversation(fromJSONDictionary: conversationDictionary)
        
        client.addNewRecipientsIDs(["4", "5", "6"], toConversation: conversation)
        XCTAssertEqual(client.capturedPath!, "/api/v1/conversations/2/add_recipients", "CKIConversation returned API path for testCreateMessageInConversationWithAttachmentIDs was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIConversation API Interaction Method was incorrect")
    }
}
