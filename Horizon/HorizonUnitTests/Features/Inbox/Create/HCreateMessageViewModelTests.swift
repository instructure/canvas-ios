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
import HorizonUI
import TestsFoundation
import XCTest
import Combine
import CombineSchedulers

final class HCreateMessageViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var testee: HCreateMessageViewModel!
    private var mockComposeMessageInteractor: ComposeMessageInteractorMock!
    private var mockInboxMessageInteractor: InboxMessageInteractorMock!
    private var mockRecipientsSearch: RecipientsSearchInteractorMock!
    private var mockAcknowledgeFileUploadInteractor: AcknowledgeFileUploadInteractorMock!
    private var recipientSelectionViewModel: RecipientSelectionViewModel!
    private var attachmentViewModel: AttachmentViewModel!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockComposeMessageInteractor = ComposeMessageInteractorMock()
        mockInboxMessageInteractor = InboxMessageInteractorMock()
        mockRecipientsSearch = RecipientsSearchInteractorMock()
        mockAcknowledgeFileUploadInteractor = AcknowledgeFileUploadInteractorMock()
        testScheduler = DispatchQueue.test

        recipientSelectionViewModel = RecipientSelectionViewModel(
            userID: "test-user-id",
            dispatchQueue: testScheduler.eraseToAnyScheduler(),
            recipientsSearch: mockRecipientsSearch
        )

        attachmentViewModel = AttachmentViewModel(
            composeMessageInteractor: mockComposeMessageInteractor,
            acknowledgeFileUploadInteractor: mockAcknowledgeFileUploadInteractor
        )

        testee = makeViewModel()
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        recipientSelectionViewModel = nil
        attachmentViewModel = nil
        mockComposeMessageInteractor = nil
        mockInboxMessageInteractor = nil
        mockRecipientsSearch = nil
        mockAcknowledgeFileUploadInteractor = nil
        testScheduler = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeViewModel() -> HCreateMessageViewModel {
        HCreateMessageViewModel(
            userID: "test-user-id",
            attachmentViewModel: attachmentViewModel,
            recipientSelectionViewModel: recipientSelectionViewModel,
            composeMessageInteractor: mockComposeMessageInteractor,
            inboxMessageInteractor: mockInboxMessageInteractor,
            router: router,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
    }

    private func makeCourse(id: String, name: String) -> InboxCourse {
        let newCourse: InboxCourse = databaseClient.insert()
        newCourse.courseId = id
        newCourse.name = name
        return newCourse
    }

    func test_init_shouldSetInitialState() {
        // Given
        let viewModel = makeViewModel()

        // When
        // Initialization happens in makeViewModel()

        // Then
        XCTAssertEqual(viewModel.body, "")
        XCTAssertEqual(viewModel.subject, "")
        XCTAssertFalse(viewModel.isCourseFocused)
        XCTAssertFalse(viewModel.isSending)
        XCTAssertTrue(viewModel.courses.isEmpty)
    }

    func test_init_shouldSubscribeToCoursesPublisher() {
        // Given
        let courses = [
            makeCourse(id: "1", name: "Math 101"),
            makeCourse(id: "2", name: "Science 101")
        ]

        // When
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.courses.count, 2)
        XCTAssertEqual(testee.courses[0], "Math 101")
        XCTAssertEqual(testee.courses[1], "Science 101")
    }

    func test_init_shouldSetSelectedCourse_whenCoursesReceived() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]

        // When
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.selectedCourse, "Math 101")
    }

    func test_init_shouldSubscribeToRecipientFocusSubject() {
        // Given
        testee.isCourseFocused = true

        // When
        recipientSelectionViewModel.isFocusedSubject.accept(true)
        testScheduler.advance()

        // Then
        XCTAssertFalse(testee.isCourseFocused)
    }

    func test_selectedCourse_setter_shouldClearRecipientSearch() {
        // Given
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ])
        let courses = [makeCourse(id: "course-123", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()

        // When
        testee.selectedCourse = "Math 101"

        // Then
        XCTAssertTrue(recipientSelectionViewModel.searchByPersonSelections.isEmpty)
    }

    func test_selectedCourse_setter_shouldSetRecipientFocusToFalse() {
        // Given
        recipientSelectionViewModel.isFocusedSubject.accept(true)
        let courses = [makeCourse(id: "course-123", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()

        // When
        testee.selectedCourse = "Math 101"

        // Then
        XCTAssertFalse(recipientSelectionViewModel.isFocusedSubject.value)
    }

    func test_selectedCourse_setter_shouldSetContextOnRecipientViewModel() {
        // Given
        let courses = [makeCourse(id: "course-456", name: "Science 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()

        // When
        testee.selectedCourse = "Science 101"
        testScheduler.advance(by: .milliseconds(250))

        // Then
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, 1)
        XCTAssertEqual(mockRecipientsSearch.lastSearchContext, Context.course("course-456"))
    }

    func test_isSendDisabled_shouldReturnTrue_whenSelectedCourseIsEmpty() {
        // Given
        testee.selectedCourse = ""
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenSubjectIsEmpty() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = ""
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenSubjectIsWhitespace() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "   "
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenBodyIsEmpty() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = ""
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenBodyIsWhitespace() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "   "
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenRecipientsAreEmpty() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnTrue_whenIsSending() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])
        testee.isSending = true

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertTrue(result)
    }

    func test_isSendDisabled_shouldReturnFalse_whenAllConditionsAreMet() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])

        // When
        let result = testee.isSendDisabled

        // Then
        XCTAssertFalse(result)
    }

    func test_attachFile_shouldSetAttachmentViewModelVisible() {
        // Given
        let viewController = WeakViewController()
        attachmentViewModel.isVisible = false

        // When
        testee.attachFile(from: viewController)

        // Then
        XCTAssertTrue(attachmentViewModel.isVisible)
    }

    func test_close_shouldDeleteAllAttachments() {
        // Given
        let mockFile = File.make()
        mockComposeMessageInteractor.simulateAttachments([mockFile])
        let viewController = WeakViewController()

        // When
        testee.close(viewController: viewController)

        // Then
        XCTAssertEqual(mockComposeMessageInteractor.removeFileCallCount, 1)
        XCTAssertEqual(mockComposeMessageInteractor.lastRemovedFile?.id, mockFile.id)
    }

    func test_close_shouldDismissViewController() {
        // Given
        let viewController = WeakViewController()

        // When
        testee.close(viewController: viewController)

        // Then
        XCTAssertNotNil(router.dismissed)
    }

    func test_sendMessage_shouldSetIsSendingToTrue() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])
        let viewController = WeakViewController()
        mockComposeMessageInteractor.createConversationResult = .success(nil)
        mockInboxMessageInteractor.setContextResult = .success(())
        mockInboxMessageInteractor.setScopeResult = .success(())
        mockInboxMessageInteractor.refreshResult = .success(())

        // When
        testee.sendMessage(viewController: viewController)

        // Then
        XCTAssertTrue(testee.isSending)
    }

    func test_sendMessage_shouldCallCreateConversationWithCorrectParameters() {
        // Given
        let courses = [makeCourse(id: "course-123", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "recipient-1", label: "John")
        ])
        let viewController = WeakViewController()
        mockComposeMessageInteractor.createConversationResult = .success(nil)
        mockInboxMessageInteractor.setContextResult = .success(())
        mockInboxMessageInteractor.setScopeResult = .success(())
        mockInboxMessageInteractor.refreshResult = .success(())

        // When
        testee.sendMessage(viewController: viewController)
        testScheduler.advance()

        // Then
        XCTAssertEqual(mockComposeMessageInteractor.createConversationCallCount, 1)
        XCTAssertEqual(mockComposeMessageInteractor.lastCreateConversationParameters?.subject, "Test Subject")
        XCTAssertEqual(mockComposeMessageInteractor.lastCreateConversationParameters?.body, "Test Body")
        XCTAssertEqual(mockComposeMessageInteractor.lastCreateConversationParameters?.recipientIDs, ["recipient-1"])
        XCTAssertEqual(mockComposeMessageInteractor.lastCreateConversationParameters?.context, .course("course-123"))
        XCTAssertEqual(mockComposeMessageInteractor.lastCreateConversationParameters?.bulkMessage, false)
    }

    func test_sendMessage_shouldRefreshSentMessages() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])
        let viewController = WeakViewController()
        mockComposeMessageInteractor.createConversationResult = .success(nil)
        mockInboxMessageInteractor.setContextResult = .success(())
        mockInboxMessageInteractor.setScopeResult = .success(())
        mockInboxMessageInteractor.refreshResult = .success(())

        // When
        testee.sendMessage(viewController: viewController)
        testScheduler.advance()

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.setContextCallCount, 1)
        XCTAssertEqual(mockInboxMessageInteractor.lastSetContext, .user("test-user-id"))
        XCTAssertEqual(mockInboxMessageInteractor.setScopeCallCount, 1)
        XCTAssertEqual(mockInboxMessageInteractor.lastSetScope, .sent)
        XCTAssertEqual(mockInboxMessageInteractor.refreshCallCount, 1)
    }

    func test_sendMessage_shouldDismissViewController_onSuccess() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])
        let viewController = WeakViewController()
        mockComposeMessageInteractor.createConversationResult = .success(nil)
        mockInboxMessageInteractor.setContextResult = .success(())
        mockInboxMessageInteractor.setScopeResult = .success(())
        mockInboxMessageInteractor.refreshResult = .success(())

        // When
        testee.sendMessage(viewController: viewController)
        testScheduler.advance()

        // Then
        XCTAssertNotNil(router.dismissed)
    }

    func test_sendMessage_shouldNotDismissViewController_onFailure() {
        // Given
        let courses = [makeCourse(id: "1", name: "Math 101")]
        mockInboxMessageInteractor.courses.send(courses)
        testScheduler.advance()
        testee.subject = "Test Subject"
        testee.body = "Test Body"
        recipientSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ])
        let viewController = WeakViewController()
        mockComposeMessageInteractor.createConversationResult = .failure(NSError(domain: "test", code: 1))

        // When
        testee.sendMessage(viewController: viewController)
        testScheduler.advance()

        // Then
        XCTAssertNil(router.dismissed)
    }
}
