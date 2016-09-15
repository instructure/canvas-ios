//
//  ConversationTests.swift
//  MessageKitTests
//
//  Created by Nathan Armstrong on 6/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import MessageKit
import XCTest
import SoAutomated
import TooLegit
import SoPersistent
import CoreData
import SoLazy
import Marshal

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: DescribeSyncingConversations.self) }
}

import ReactiveCocoa
extension SignalProducerType {
    func startWithStub(stub: Stub, file: StaticString = #file, line: UInt = #line, next: (Value -> Void)?) {
        stub.testCase.stub(stub.session, stub.name) { expectation in
            self.startWithCompletedExpectation(expectation) { value in
                next?(value)
            }
        }
    }
}

// MARK: - Fetching

class DescribeFetchingConversations: XCTestCase {
    let session = User1().session

    func testItReturnsAnArrayOfJSON() {
        try! Conversation.getConversations(session).startWithStub(stub(session, with: "conversations")) { conversations in
            XCTAssertEqual(2, conversations.count)
        }
    }
}

// MARK: - Syncing

class DescribeSyncingConversations: XCTestCase {
    let session = User1().session

    func testItCreatesConversations() {
        let count = { Conversation.count(inContext: try! self.session.messagesManagedObjectContext()) }
        assertDifference(count, 2) {
            try! Conversation.syncSignalProducer(session).startWithStub(stub(session, with: "conversations"), next: nil)
        }
    }
}

class ConversationTests: UnitTestCase {
    func testConversations_api_itReturnsAllConversations() {
        let user = User1()
        let context = Context(user: user, testCase: self)
        let conversations = context.getConversations(fixture: "conversations")
        XCTAssertEqual(2, conversations.count ?? 0, "it returns the correct number of conversations")
    }

    func testConversations_sync_itSyncsAllConversations() {
        let user = User1()
        let context = Context(user: user, testCase: self)
        context.syncConversations(fixture: "conversations")
        attempt {
            let moc = try user.session.messagesManagedObjectContext()
            XCTAssertEqual(2, Conversation.count(inContext: moc), "it syncs the correct number of conversations")
        }
    }

    func testConversation_mostRecentSender_whenThereIsOneParticipant_isTheNameOfTheParticipant() {
        let conversation = whenThereIsOneParticipant()
        XCTAssertEqual("User 2", conversation.mostRecentSender.name, "nameOfLastSender is a match")
    }

    func testConversation_nameOfLastSender_whenThereAreMultipleParticipants_isTheCorrectParticipant() {
        let conversation = whenThereAreMultipleParticipants()
        XCTAssertEqual("User 2", conversation.mostRecentSender.name, "nameOfLastSender is a match")
    }

    func testConversation_numberOfParticipants_whenThereIsOneParticipant_isOne() {
        let conversation = whenThereIsOneParticipant()
        XCTAssertEqual(1, conversation.numberOfParticipants, "it has one participant")
    }

    func testConversation_numberOfParticipants_whenThereAreManyParticipants_isTheNumberOfParticipants() {
        let conversation = whenThereAreMultipleParticipants()
        XCTAssertEqual(2, conversation.numberOfParticipants, "the count is correct")
    }

    func testConversation_date_matchesResponse() {
        let conversation = whenThereIsOneParticipant()
        let expectedDate = NSDate(year: 2016, month: 7, day: 1)
        XCTAssert(expectedDate.isTheSameDayAsDate(conversation.date), "it matches the expected date")
    }

    func testConversation_subject_whenThereIsNoSubject_itIsAnEmptyString() {
        let conversation = whenThereIsNotASubject()
        XCTAssert(conversation.subject.isEmpty, "it has an empty subject")
    }

    func testConversation_subject_whenThereIsASubject_itIsTheSubject() {
        let conversation = whenThereIsOneParticipant()
        XCTAssertEqual("This is a Subject Line Demo", conversation.subject, "it has a subject")
    }

    func testConversation_itHasTheMostRecentMessage() {
        let conversation = whenThereIsOneParticipant()
        XCTAssertEqual("This is sample text that shows the first part.", conversation.mostRecentMessage, "it has the most recent message")
    }

    func testConversation_whenThereIsOneParticipant_hasParticipantAvatar() {
        let conversation = whenThereIsOneParticipant()
        XCTAssertEqual(1, conversation.participantAvatars.count, "it has one participant avatar")
    }

    func testConversation_whenThereAreMultipleParticipants_hasAllParticipantAvatars() {
        let conversation = whenThereAreMultipleParticipants()
        XCTAssertEqual(2, conversation.participantAvatars.count, "it has all participant avatars")
    }

    func testConversation_workflowState_whenItIsUnread_itHasAnUnreadState() {
        let conversation = whenItIsUnread()
        XCTAssert(conversation.workflowState == .Unread, "it is unread")
    }

    func testConversation_workflowState_whenItIsRead_itHasAReadState() {
        let conversation = whenItIsRead()
        XCTAssert(conversation.workflowState == .Read, "it is read")
    }

    func testConversation_hasAttachments_whenThereAreAttachments_isTrue() {
        let conversation = whenThereAreAttachments()
        XCTAssert(conversation.hasAttachments, "it should have attachments")
    }

    func testConversation_hasAttachments_whenThereAreNotAttachments_isFalse() {
        let conversation = whenThereAreNotAttachments()
        XCTAssertFalse(conversation.hasAttachments, "it should not have attachments")
    }

    func testConversation_starred_whenItIsStarred_isTrue() {
        let conversation = whenItIsStarred()
        XCTAssert(conversation.starred, "it should be starred")
    }

    func testConversation_starred_whenItIsNotStarred_isFalse() {
        let conversation = whenItIsNotStarred()
        XCTAssertFalse(conversation.starred, "it should not be starred")
    }

    // MARK: Contexts

    private func whenThereIsOneParticipant() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116740")
    }

    private func whenThereAreMultipleParticipants() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116743")
    }

    private func whenThereIsNotASubject() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116743")
    }

    private func whenThereIsASubject() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116740")
    }

    private func whenItIsUnread() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116743")
    }

    private func whenItIsRead() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116740")
    }

    private func whenThereAreAttachments() -> Conversation {
        let context = Context(user: User2(), testCase: self)
        context.syncConversations(fixture: "conversations-1")
        return context.findConversation(id: "8116740")
    }

    private func whenThereAreNotAttachments() -> Conversation {
        let context = Context(user: User1(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116743")
    }

    private func whenItIsStarred() -> Conversation {
        let context = Context(user: User2(), testCase: self)
        context.syncConversations(fixture: "conversations-1")
        return context.findConversation(id: "8116740")
    }

    private func whenItIsNotStarred() -> Conversation {
        let context = Context(user: User2(), testCase: self)
        context.syncConversations(fixture: "conversations")
        return context.findConversation(id: "8116743")
    }
}
