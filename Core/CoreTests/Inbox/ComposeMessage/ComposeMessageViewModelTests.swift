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
        mockInteractor = ComposeMessageInteractorMock()
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
        testee.didSelectRecipient.accept(Recipient(searchRecipient: .make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.subject = ""
        XCTAssertEqual(testee.sendButtonActive, true)
    }

    func testValidationForBody() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        testee.didSelectRecipient.accept(Recipient(searchRecipient: .make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.bodyText = ""
        testee.didTapSend.accept(WeakViewController())
        XCTAssertEqual(mockInteractor.isCreateConversationCalled, true)
        XCTAssertEqual(mockInteractor.parameters?.body, String(localized: "[No message]"))
    }

    func testValidationForRecipients() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        let recipient = Recipient(searchRecipient: SearchRecipient.make())
        testee.didSelectRecipient.accept(Recipient(searchRecipient: .make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.didRemoveRecipient.accept(recipient)
        print(testee.recipients)
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testSuccessfulNewSend() {
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isCreateConversationCalled, false)
        testee.didTapSend.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isCreateConversationCalled, true)
    }

    func testSuccessfulReplySend() {
        setupForReply()
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isAddConversationMessageCalled, false)
        testee.didTapSend.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isAddConversationMessageCalled, true)
    }

    func testSuccessfulReplyAllSend() {
        setupForReplyAll()
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isAddConversationMessageCalled, false)
        testee.didTapSend.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isAddConversationMessageCalled, true)
    }

    func testSuccessfulForwardSend() {
        setupForForward()
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isAddConversationMessageCalled, false)
        testee.didTapSend.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isAddConversationMessageCalled, true)
    }

    func testFailedSend() {
        mockInteractor.isSuccessfulMockFuture = false
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        testee.didTapSend.accept(WeakViewController(sourceView))

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

        testee.didSelectRecipient.accept(Recipient(searchRecipient: .make()))
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

    func testAttachmentButton() {
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        testee.attachmentButtonDidTap(viewController: viewController)
        wait(for: [router.showExpectation], timeout: 1)

        let presented = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(presented)
    }

    func testAttachmentOptionsDialog() {
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)
        testee.attachmentButtonDidTap(viewController: viewController)

        let presented = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(presented)

        testee.isImagePickerVisible = false
        testee.isTakePhotoVisible = false
        testee.isFilePickerVisible = false
        testee.isAudioRecordVisible = false
        XCTAssertEqual(presented?.actions.count, 5)

        let uploadFileAction = presented?.actions[0]
        let uploadPhotoAction = presented?.actions[1]
        let takePhotoAction = presented?.actions[2]
        let recordAudioAction = presented?.actions[3]
        let selectFileAction = presented?.actions[4]

        XCTAssertEqual(uploadFileAction?.title, String(localized: "Upload file", bundle: .core))
        XCTAssertEqual(uploadFileAction?.image, .documentLine)
        uploadFileAction?.action()
        XCTAssertTrue(testee.isFilePickerVisible)
        XCTAssertFalse(testee.isImagePickerVisible)
        XCTAssertFalse(testee.isTakePhotoVisible)
        XCTAssertFalse(testee.isAudioRecordVisible)

        XCTAssertEqual(uploadPhotoAction?.title, String(localized: "Upload photo", bundle: .core))
        XCTAssertEqual(uploadPhotoAction?.image, .imageLine)
        uploadPhotoAction?.action()
        XCTAssertTrue(testee.isFilePickerVisible)
        XCTAssertTrue(testee.isImagePickerVisible)
        XCTAssertFalse(testee.isTakePhotoVisible)
        XCTAssertFalse(testee.isAudioRecordVisible)

        XCTAssertEqual(takePhotoAction?.title, String(localized: "Take photo", bundle: .core))
        XCTAssertEqual(takePhotoAction?.image, .cameraLine)
        takePhotoAction?.action()
        XCTAssertTrue(testee.isFilePickerVisible)
        XCTAssertTrue(testee.isImagePickerVisible)
        XCTAssertTrue(testee.isTakePhotoVisible)
        XCTAssertFalse(testee.isAudioRecordVisible)

        XCTAssertEqual(recordAudioAction?.title, String(localized: "Record audio", bundle: .core))
        XCTAssertEqual(recordAudioAction?.image, .audioLine)
        recordAudioAction?.action()
        XCTAssertTrue(testee.isFilePickerVisible)
        XCTAssertTrue(testee.isImagePickerVisible)
        XCTAssertTrue(testee.isTakePhotoVisible)
        XCTAssertTrue(testee.isAudioRecordVisible)

        XCTAssertEqual(selectFileAction?.title, String(localized: "Attach from Canvas files", bundle: .core))
        XCTAssertEqual(selectFileAction?.image, .folderLine)
        selectFileAction?.action()

        XCTAssertTrue(testee.isFilePickerVisible)
        XCTAssertTrue(testee.isImagePickerVisible)
        XCTAssertTrue(testee.isTakePhotoVisible)
        XCTAssertTrue(testee.isAudioRecordVisible)

        wait(for: [router.showExpectation], timeout: 1)

        let presentedFilePicker = router.presented as? CoreHostingController<FilePickerView>
        XCTAssertNotNil(presentedFilePicker)
    }

    func testIncludedMessagesExpansion() {
        let message1: ConversationMessage = .make(from: .make(id: "1", created_at: Date.now))
        let message2: ConversationMessage = .make(from: .make(id: "2", created_at: Date.now + 2))
        let message3: ConversationMessage = .make(from: .make(id: "3", created_at: Date.now + 3))
        let conversation: Conversation = .make()
        conversation.messages = [message1, message2, message3]
        conversation.subject = "Test subject"
        testee = ComposeMessageViewModel(router: router, options: .init(fromType: .forward(conversation: conversation, message: nil)), interactor: mockInteractor)
        XCTAssertTrue(testee.expandedIncludedMessageIds.isEmpty)

        testee.toggleMessageExpand(message: message2)
        XCTAssertEqual(testee.expandedIncludedMessageIds.count, 1)
        XCTAssertEqual(testee.expandedIncludedMessageIds.first, message2.id)

        testee.toggleMessageExpand(message: message2)
        XCTAssertEqual(testee.expandedIncludedMessageIds.count, 0)
    }

    func testAttachmentWithURLSelected() {
        testee.isImagePickerVisible = true
        testee.isTakePhotoVisible = true
        testee.isFilePickerVisible = true
        testee.isAudioRecordVisible = true
        testee.addFile(url: URL(string: "https://instructure.com")!)

        XCTAssertFalse(testee.isImagePickerVisible)
        XCTAssertFalse(testee.isTakePhotoVisible)
        XCTAssertFalse(testee.isFilePickerVisible)
        XCTAssertFalse(testee.isAudioRecordVisible)
        XCTAssertTrue(mockInteractor.isAddFileWithURLCalled)
    }

    func testAttachmentWithFileSelected() {
        testee.addFile(file: File.make())

        XCTAssertTrue(mockInteractor.isAddFileWithFileCalled)
    }
}

private class ComposeMessageInteractorMock: ComposeMessageInteractor {
    var attachments = CurrentValueSubject<[Core.File], Never>([])

    var isSuccessfulMockFuture = true
    var isCreateConversationCalled = false
    var isAddConversationMessageCalled = false
    var isAddFileWithURLCalled = false
    var isAddFileWithFileCalled = false
    var isRetryCalled = false
    var isCancelCalled = false
    var isRemoveFileCalled = false
    var parameters: MessageParameters?

    func createConversation(parameters: Core.MessageParameters) -> Future<URLResponse?, any Error> {
        self.parameters = parameters
        isCreateConversationCalled = true
        return mockFuture
    }

    func addConversationMessage(parameters: Core.MessageParameters) -> Future<URLResponse?, any Error> {
        self.parameters = parameters
        isAddConversationMessageCalled = true
        return mockFuture
    }

    func addFile(url: URL) {
        isAddFileWithURLCalled = true
    }

    func addFile(file: Core.File) {
        isAddFileWithFileCalled = true
    }

    func retry() {
        isRetryCalled = true
    }

    func cancel() {
        isCancelCalled = true
    }

    func removeFile(file: Core.File) {
        isRemoveFileCalled = true
    }

    private var mockFuture: Future<URLResponse?, Error> {
        isSuccessfulMockFuture ? mockSuccessFuture : mockFailedFuture
    }

    private var mockFailedFuture: Future<URLResponse?, Error> {
        Future<URLResponse?, Error> { promise in
            promise(.failure("Fail"))
        }
    }

    private var mockSuccessFuture: Future<URLResponse?, Error> {
        Future<URLResponse?, Error> { promise in
            promise(.success(nil))
        }
    }
}
