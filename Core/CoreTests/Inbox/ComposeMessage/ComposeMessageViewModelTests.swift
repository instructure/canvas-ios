//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Combine
@testable import Core
import CoreData
import XCTest

class ComposeMessageViewModelTests: CoreTestCase {
    private var mockInteractor: ComposeMessageInteractorMock!
    var testee: ComposeMessageViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = ComposeMessageInteractorMock(context: databaseClient)
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .new), interactor: mockInteractor)
    }

    private func setupForReply() {
        let conversation: Conversation = .make()
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .reply(conversation: conversation, message: nil)), interactor: mockInteractor)
    }

    private func setupForReplyAll() {
        let conversation: Conversation = .make()
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .replyAll(conversation: conversation, message: nil)), interactor: mockInteractor)
    }

    private func setupForForward() {
        let conversation: Conversation = .make()
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .forward(conversation: conversation, message: nil)), interactor: mockInteractor)
    }

    func testValidationForSubject() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        testee.recipientDidSelect.accept(Recipient(searchRecipient: .make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.subject = ""
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testValidationForBody() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        testee.recipientDidSelect.accept(Recipient(searchRecipient: .make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.bodyText = ""
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testValidationForRecipients() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        let recipient = Recipient(searchRecipient: SearchRecipient.make())
        testee.recipientDidSelect.accept(Recipient(searchRecipient: .make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.recipientDidRemove.accept(recipient)
        print(testee.recipients)
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testSuccesfulNewSend() {
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isConversationAddSent, false)
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isConversationAddSent, true)
    }

    func testSuccesfulReplySend() {
        setupForReply()
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isMessageAddSent, false)
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isMessageAddSent, true)
    }

    func testSuccesfulReplyAllSend() {
        setupForReplyAll()
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isMessageAddSent, false)
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isMessageAddSent, true)
    }

    func testSuccesfulForwardSend() {
        setupForForward()
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isMessageAddSent, false)
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isMessageAddSent, true)
    }

    func testFailedSend() {
        mockInteractor.isSuccessfulMockFuture = false
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? UIAlertController
        XCTAssertNotNil(dialog)
        XCTAssertEqual(dialog?.title, "Message could not be sent")
        XCTAssertEqual(dialog?.message, "Please try again!")
        XCTAssertEqual(dialog?.actions.count, 1)
        XCTAssertEqual(dialog?.actions.first?.title, "OK")
    }

    func testShowCourseSelector() {
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        testee.courseSelectButtonDidTap(viewController: viewController)
        wait(for: [router.showExpectation], timeout: 1)

        testee.recipientDidSelect.accept(Recipient(searchRecipient: .make()))
        XCTAssertEqual(testee.selectedRecipients.value.count, 1)

        testee.courseDidSelect(selectedContext: .init(course: .make()), viewController: viewController)

        XCTAssertEqual(testee.selectedRecipients.value.count, 0)
    }

    func testShowRecipientSelector() {
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        testee.selectedContext = RecipientContext(course: Course.make())
        testee.addRecipientButtonDidTap(viewController: viewController)

        wait(for: [router.showExpectation], timeout: 1)
        XCTAssertNotNil(router.presented)
    }

    func testReplyMessageValues() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .reply(conversation: conversation, message: message2)), interactor: mockInteractor)

        XCTAssertEqual(testee.subject, "Test subject")
        XCTAssertEqual(testee.selectedContext?.name, conversation.contextName)
        XCTAssertEqual(testee.recipients.first?.ids.first, message2.authorID)
        XCTAssertEqual(testee.includedMessages, [message1, message2])
    }

    func testReplyConversationValues() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .reply(conversation: conversation, message: nil)), interactor: mockInteractor)

        XCTAssertEqual(testee.subject, "Test subject")
        XCTAssertEqual(testee.selectedContext?.name, conversation.contextName)
        XCTAssertEqual(testee.recipients.first?.ids.first, message2.authorID)
        XCTAssertEqual(testee.includedMessages, [message1, message2, message3])
    }

    func testReplyAllMessageValues() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .replyAll(conversation: conversation, message: nil)), interactor: mockInteractor)

        XCTAssertEqual(testee.subject, "Test subject")
        XCTAssertEqual(testee.selectedContext?.name, conversation.contextName)
        XCTAssertEqual(testee.recipients.flatMap { $0.ids }, conversation.participants.map { $0.id })
        XCTAssertEqual(testee.includedMessages, [message1, message2, message3])
    }

    func testReplyAllConversationValues() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .replyAll(conversation: conversation, message: nil)), interactor: mockInteractor)

        XCTAssertEqual(testee.subject, "Test subject")
        XCTAssertEqual(testee.selectedContext?.name, conversation.contextName)
        XCTAssertEqual(testee.recipients.flatMap { $0.ids }, conversation.participants.map { $0.id })
        XCTAssertEqual(testee.includedMessages, [message1, message2, message3])
    }

    func testForwardMessageValues() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .forward(conversation: conversation, message: message2)), interactor: mockInteractor)

        XCTAssertEqual(testee.subject, "Fw: Test subject")
        XCTAssertEqual(testee.selectedContext?.name, conversation.contextName)
        XCTAssertEqual(testee.recipients.count, 0)
        XCTAssertEqual(testee.includedMessages, [message2])
    }

    func testForwardConversationValues() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .forward(conversation: conversation, message: nil)), interactor: mockInteractor)

        XCTAssertEqual(testee.subject, "Fw: Test subject")
        XCTAssertEqual(testee.selectedContext?.name, conversation.contextName)
        XCTAssertEqual(testee.recipients.count, 0)
        XCTAssertEqual(testee.includedMessages, [message1, message2, message3])
    }
}

private class ComposeMessageInteractorMock: ComposeMessageInteractor {
    var state: CurrentValueSubject<Core.StoreState, Never>
    var courses: CurrentValueSubject<[Core.InboxCourse], Never>

    var isSuccessfulMockFuture = true
    var isMessageAddSent = false
    var isConversationAddSent = false

    init(context: NSManagedObjectContext) {
        self.state = .init(.data)
        self.courses = .init(.make(count: 5, in: context))
    }

    func createConversation(parameters: MessageParameters) -> Future<Void, Error> {
        isConversationAddSent = true
        return mockFuture
    }

    func addConversationMessage(parameters: MessageParameters) -> Future<Void, Error> {
        isMessageAddSent = true
        return mockFuture
    }

    private var mockFuture: Future<Void, Error> {
        isSuccessfulMockFuture ? mockSuccessFuture : mockFailedFuture
    }

    private var mockFailedFuture: Future<Void, Error> {
        Future<Void, Error> { promise in
            promise(.failure("Fail"))
        }
    }

    private var mockSuccessFuture: Future<Void, Error> {
        Future<Void, Error> { promise in
            promise(.success(()))
        }
    }
}
