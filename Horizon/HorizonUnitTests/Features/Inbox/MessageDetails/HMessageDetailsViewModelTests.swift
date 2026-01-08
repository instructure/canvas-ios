//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
@testable import Horizon
import TestsFoundation
import XCTest
import Combine
import CombineSchedulers

final class HMessageDetailsViewModelTests: HorizonTestCase {
    // MARK: - Properties

    private var testee: HMessageDetailsViewModel!
    private var mockMessageDetailsInteractor: MessageDetailsInteractorMock!
    private var mockComposeMessageInteractor: ComposeMessageInteractorMock!
    private var mockDownloadFileInteractor: DownloadFileInteractorMock!
    private var mockAcknowledgeFileUploadInteractor: AcknowledgeFileUploadInteractorMock!
    private var attachmentViewModel: AttachmentViewModel!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockMessageDetailsInteractor = MessageDetailsInteractorMock()
        mockComposeMessageInteractor = ComposeMessageInteractorMock()
        mockDownloadFileInteractor = DownloadFileInteractorMock()
        mockAcknowledgeFileUploadInteractor = AcknowledgeFileUploadInteractorMock()
        testScheduler = DispatchQueue.test
        attachmentViewModel = AttachmentViewModel(
            composeMessageInteractor: mockComposeMessageInteractor,
            acknowledgeFileUploadInteractor: mockAcknowledgeFileUploadInteractor
        )
        testee = makeViewModel()
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        attachmentViewModel = nil
        mockMessageDetailsInteractor = nil
        mockComposeMessageInteractor = nil
        mockDownloadFileInteractor = nil
        mockAcknowledgeFileUploadInteractor = nil
        testScheduler = nil
        super.tearDown()
    }

    private func makeViewModel(conversationID: String = "conv-123") -> HMessageDetailsViewModel {
        HMessageDetailsViewModel(
            conversationID: conversationID,
            router: router,
            userID: "user-123",
            attachmentViewModel: attachmentViewModel,
            messageDetailsInteractor: mockMessageDetailsInteractor,
            composeMessageInteractor: mockComposeMessageInteractor,
            downloadFileInteractor: mockDownloadFileInteractor,
            allowArchive: true,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
    }

    private func makeConversationMessage(id: String, authorID: String, body: String) -> ConversationMessage {
        let message = ConversationMessage.make(in: databaseClient)
        message.id = id
        message.authorID = authorID
        message.body = body
        message.createdAt = Date()
        return message
    }

    private func makeConversation(id: String, subject: String) -> Conversation {
        let conversation = Conversation.make(in: databaseClient)
        conversation.id = id
        conversation.subject = subject
        return conversation
    }

    func test_init_shouldSetInitialState() {
        // Given
        let testee = makeViewModel()

        // When

        // Then

        XCTAssertEqual(testee.reply, "")
        XCTAssertFalse(testee.isSending)
        XCTAssertTrue(testee.messages.isEmpty)
    }

    func test_init_shouldMarkConversationAsRead() {
        // Given
        let conversationID = "conv-456"
        // When
        _ = makeViewModel(conversationID: conversationID)
        // Then
        XCTAssertEqual(mockMessageDetailsInteractor.lastUpdateStateMessageId, conversationID)
    }

    func test_init_shouldListenForMessages() {
        // Given
        let message1 = makeConversationMessage(id: "msg-1", authorID: "author-1", body: "Hello")
        let message2 = makeConversationMessage(id: "msg-2", authorID: "author-2", body: "World")
        mockMessageDetailsInteractor.userMap = [
            "author-1": makeConversationParticipant(name: "John"),
            "author-2": makeConversationParticipant(name: "Jane")
        ]
        // When
        mockMessageDetailsInteractor.simulateMessages([message2, message1])
        testScheduler.advance()
        // Then
        XCTAssertEqual(testee.messages.count, 2)
        XCTAssertEqual(testee.messages[0].id, "msg-1")
        XCTAssertEqual(testee.messages[1].id, "msg-2")
    }

    func test_init_shouldListenForSubject() {
        // Given
        let conversation = makeConversation(id: "conv-123", subject: "Test Subject")
        // When

        mockMessageDetailsInteractor.simulateConversation([conversation])
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.headerTitle, "Test Subject")
    }

    func test_init_shouldShowDefaultTitle_whenNoConversation() {
        // Given
        mockMessageDetailsInteractor.simulateConversation([])

        // When
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.headerTitle, "Conversation")
    }

    func test_isSendDisabled_shouldReturnTrue_whenReplyIsEmpty() {
        // Given
        testee.reply = ""

        // When

        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenReplyIsWhitespace() {
        // Given
        testee.reply = "   "

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenIsSending() {
        // Given
        testee.reply = "Test message"
        testee.isSending = true

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnFalse_whenConditionsMet() {
        // Given
        testee.reply = "Test message"
        testee.isSending = false

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertFalse(result)
    }

    func test_attachFile_shouldShowAttachmentPicker() {
        // Given
        XCTAssertFalse(attachmentViewModel.isVisible)

        // When
        testee.attachFile(viewController: WeakViewController())

        // Then
        XCTAssertTrue(attachmentViewModel.isVisible)
    }

    func test_pop_shouldDeleteAllAttachments() {
        // Given
        let file = File.make()
        mockComposeMessageInteractor.simulateAttachments([file])

        // When
        testee.pop(viewController: WeakViewController())

        // Then
        XCTAssertEqual(mockComposeMessageInteractor.removeFileCallCount, 1)
    }

    func test_pop_shouldPopRouter() {
        // Given
        let viewController = WeakViewController()
        // When
        testee.pop(viewController: viewController)

        // Then
        wait(for: [router.popExpectation], timeout: 0.1)
        XCTAssertNotNil(router.popped)
    }

    func test_refresh_shouldCallRefreshOnInteractor() {
        // When
        testee.refresh()

        // Then
        XCTAssertEqual(mockMessageDetailsInteractor.refreshCallCount, 1)
    }

    func test_refresh_shouldCallFinishClosure() {
        // Given
        var finishCalled = false
        // When
        testee.refresh {
            finishCalled = true
        }
        // Then
        XCTAssertTrue(finishCalled)
    }

    func test_sendMessage_shouldSetIsSendingToTrue() {
        // Given
        setupValidMessageState()
        // When
        testee.sendMessage(viewController: WeakViewController())
        // Then
        XCTAssertTrue(testee.isSending)
    }

    func test_sendMessage_shouldNotSend_whenReplyIsEmpty() {
        // Given
        setupValidMessageState()
        testee.reply = ""

        // When
        testee.sendMessage(viewController: WeakViewController())

        // Then
        XCTAssertEqual(mockComposeMessageInteractor.addConversationMessageCallCount, 0)
    }

    func test_sendMessage_shouldNotSend_whenNoConversation() {
        // Given
        testee.reply = "Test message"
        mockMessageDetailsInteractor.simulateConversation([])
        // When
        testee.sendMessage(viewController: WeakViewController())
        // Then
        XCTAssertEqual(mockComposeMessageInteractor.addConversationMessageCallCount, 0)
    }

    func test_sendMessage_shouldCallAddConversationMessage() {
        // Given
        setupValidMessageState()
        mockComposeMessageInteractor.addConversationMessageResult = .success(nil)
        // When
        testee.sendMessage(viewController: WeakViewController())
        testScheduler.advance()
        // Then
        XCTAssertEqual(mockComposeMessageInteractor.addConversationMessageCallCount, 1)
    }

    func test_sendMessage_shouldResetState_afterSuccess() {
        // Given
        setupValidMessageState()
        mockComposeMessageInteractor.addConversationMessageResult = .success(nil)
        testee.reply = "Test message"
        // When
        testee.sendMessage(viewController: WeakViewController())
        testScheduler.advance()
        // Then
        XCTAssertFalse(testee.isSending)
        XCTAssertEqual(testee.reply, "")
    }

    func test_sendMessage_shouldFilterOutCurrentUser_fromRecipients() {
        // Given
        setupValidMessageState()
        mockComposeMessageInteractor.addConversationMessageResult = .success(nil)
        mockMessageDetailsInteractor.userMap = [
            "user-123": makeConversationParticipant(name: "Me"),
            "user-456": makeConversationParticipant(name: "Other")
        ]
        // When
        testee.sendMessage(viewController: WeakViewController())
        testScheduler.advance()
        // Then
        let parameters = mockComposeMessageInteractor.lastAddConversationMessageParameters
        XCTAssertEqual(parameters?.recipientIDs, ["user-456"])
        XCTAssertFalse(parameters?.recipientIDs.contains("user-123") ?? true)
    }

    func test_startDownload_shouldCallDownloadInteractor() {
        // Given
        let file = File.make()
        file.id = "file-123"
        let attachment = AttachmentFileModel(file: file)
        setupMessageWithAttachment(attachment: attachment)
        mockDownloadFileInteractor.downloadFileResult = .success(URL(fileURLWithPath: "/tmp/test.pdf"))
        // When
        testee.startDownload(
            messageID: "msg-1",
            attachment: attachment,
            viewController: WeakViewController()
        )
        // Then
        XCTAssertEqual(mockDownloadFileInteractor.downloadFileCallCount, 1)
        XCTAssertEqual(mockDownloadFileInteractor.lastDownloadedFile?.id, "file-123")
    }

    func test_startDownload_shouldShowShareSheet_onSuccess() {
        // Given
        let file = File.make()
        file.id = "file-123"
        let attachment = AttachmentFileModel(file: file)
        setupMessageWithAttachment(attachment: attachment)
        mockDownloadFileInteractor.downloadFileResult =
            .success(URL(fileURLWithPath: "/tmp/test.pdf"))
        // When
        testee.startDownload(
            messageID: "msg-1",
            attachment: attachment,
            viewController: WeakViewController()
        )
        testScheduler.advance()
        // Then
        XCTAssertTrue(router.presented is CoreActivityViewController)
    }

    func test_startDownload_shouldNotStartTwice_whenAlreadyDownloading() {
        // Given
        let file = File.make()
        file.id = "file-123"
        let attachment = AttachmentFileModel(file: file)
        setupMessageWithAttachment(attachment: attachment)
        mockDownloadFileInteractor.downloadDelay = 1.0
        mockDownloadFileInteractor.downloadFileResult =
            .success(URL(fileURLWithPath: "/tmp/test.pdf"))
        // When
        testee.startDownload(messageID: "msg-1", attachment: attachment, viewController: WeakViewController())
        testee.startDownload(messageID: "msg-1", attachment: attachment, viewController: WeakViewController())
        // Then
        XCTAssertEqual(mockDownloadFileInteractor.downloadFileCallCount, 1)
    }

    func test_attachmentItems_shouldReturnAttachmentViewModelItems() {
        // Given
        let file = File.make()
        mockComposeMessageInteractor.simulateAttachments([file])
        // When
        let items = testee.attachmentItems
        // Then
        XCTAssertEqual(items.count, 1)
    }

    func test_messages_shouldBeSortedByDate() {
        // Given
        let oldMessage = makeConversationMessage(id: "msg-1", authorID: "user-1", body: "Old")
        oldMessage.createdAt = Date(timeIntervalSince1970: 1000)
        let newMessage = makeConversationMessage(id: "msg-2", authorID: "user-2", body: "New")
        newMessage.createdAt = Date(timeIntervalSince1970: 2000)
        // When
        mockMessageDetailsInteractor.simulateMessages([newMessage, oldMessage])
        testScheduler.advance()
        // Then
        XCTAssertEqual(testee.messages.count, 2)
        XCTAssertEqual(testee.messages[0].id, "msg-1")
        XCTAssertEqual(testee.messages[1].id, "msg-2")
    }

    private func setupValidMessageState() {
        let conversation = makeConversation(id: "conv-123", subject: "Test Subject")
        mockMessageDetailsInteractor.simulateConversation([conversation])
        mockMessageDetailsInteractor.userMap = [
            "user-456": makeConversationParticipant(name: "Jane")
        ]
        testee.reply = "Test message"
        testScheduler.advance()
    }

    private func setupMessageWithAttachment(attachment: AttachmentFileModel) {
        let message = makeConversationMessage(id: "msg-1", authorID: "user-1", body: "Hello")
        message.attachments.append(attachment.file)
        mockMessageDetailsInteractor.simulateMessages([message])
        testScheduler.advance()
    }

    private func makeConversationParticipant(name: String) -> ConversationParticipant {
        let newParticipant: ConversationParticipant = databaseClient.insert()
        newParticipant.name = name
        return newParticipant
    }
}
