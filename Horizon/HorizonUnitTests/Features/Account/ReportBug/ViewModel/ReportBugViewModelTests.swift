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
import XCTest
import Combine
import CombineSchedulers

final class ReportBugViewModelTests: HorizonTestCase {

    private let testData = (
        subject: "some subject",
        description: "some description",
        topic: "General help",
        email: "test@example.com",
        baseURL: "https://career.test.com"
    )

    private var testee: ReportBugViewModel!
    private var getUserInteractor: GetUserInteractorMock!

    override func setUp() {
        super.setUp()

        // Given
        let user: UserProfile = databaseClient.insert()
        user.email = testData.email
        getUserInteractor = GetUserInteractorMock(user: user)
    }

    override func tearDown() {
        testee = nil
        getUserInteractor = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_givenUserLoadsSuccessfully_whenViewModelCreated_thenStateIsDataAndNoErrorShown() {
        // Given
        let expectation = expectation(description: "Wait for user load")
        getUserInteractor.onGetUser = { expectation.fulfill() }

        // When
        testee = makeViewModel()
        wait(for: [expectation], timeout: 0.1)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isShowError, false)
    }

    func test_init_givenUserLoadFails_whenViewModelCreated_thenStateIsDataAndErrorIsShown() {
        // Given
        let expectation = expectation(description: "Wait for user load")
        getUserInteractor.shouldFail = true
        getUserInteractor.onGetUser = { expectation.fulfill() }

        // When
        testee = makeViewModel()
        wait(for: [expectation], timeout: 0.1)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isShowError, true)
        XCTAssertNotEqual(testee.errorMessage, "")
    }

    // MARK: - List topics

    func test_listTopics_givenViewModelInitialized_thenAllTopicsAreAvailable() {
        // Given
        testee = makeViewModel()

        // Then
        XCTAssertEqual(testee.listTopics.count, 5)
        XCTAssertEqual(testee.listTopics[0], "Suggestion or comment")
        XCTAssertEqual(testee.listTopics[1], "General help")
        XCTAssertEqual(testee.listTopics[2], "Minor issue")
        XCTAssertEqual(testee.listTopics[3], "Urgent issue")
        XCTAssertEqual(testee.listTopics[4], "Critical system error")
    }

    // MARK: - Form validation

    func test_isSubmitEnabled_givenAllFieldsEmpty_thenSubmitIsDisabled() {
        // Given
        testee = makeViewModel()

        // Then
        XCTAssertEqual(testee.formValidation.isValid, false)
    }

    func test_isSubmitEnabled_givenOnlyTopicSet_thenSubmitIsDisabled() {
        // Given
        testee = makeViewModel()
        testee.selectedTopic = testData.topic

        // Then
        XCTAssertEqual(testee.formValidation.isValid, false)
    }

    func test_isSubmitEnabled_givenOnlySubjectSet_thenSubmitIsDisabled() {
        // Given
        testee = makeViewModel()
        testee.subject = testData.subject

        // Then
        XCTAssertEqual(testee.formValidation.isValid, false)
    }

    func test_isSubmitEnabled_givenOnlyDescriptionSet_thenSubmitIsDisabled() {
        // Given
        testee = makeViewModel()
        testee.description = testData.description

        // Then
        XCTAssertEqual(testee.formValidation.isValid, false)
    }

    func test_isSubmitEnabled_givenTopicAndSubjectSet_thenSubmitIsDisabled() {
        // Given
        testee = makeViewModel()
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject

        // Then
        XCTAssertEqual(testee.formValidation.isValid, false)
    }

    func test_isSubmitEnabled_givenAllFieldsSet_thenSubmitIsEnabled() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, value: ReportBugResponse(logged: true, id: "123"))

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertEqual(testee.formValidation.isValid, true)
    }

    func test_isSubmitEnabled_givenFieldsContainOnlyWhitespace_thenSubmitIsDisabled() {
        // Given
        testee = makeViewModel()
        testee.selectedTopic = "   "
        testee.subject = "  \n  "
        testee.description = "\n\n"

        // Then
        XCTAssertEqual(testee.formValidation.isValid, false)
    }

    func test_isSubmitEnabled_givenFieldsContainValidContentWithWhitespace_thenSubmitIsEnabled() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = "  " + testData.topic + "  "
        testee.subject = "\n" + testData.subject + "\n"
        testee.description = "  " + testData.description + "  "

        let request = ReportBugRequest(
            subject: "\n" + testData.subject + "\n",
            topic: "  " + testData.topic + "  ",
            description: "  " + testData.description + "  ",
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, value: ReportBugResponse(logged: true, id: "123"))

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertEqual(testee.formValidation.isValid, true)
    }

    // MARK: - Validation error messages

    func test_validationErrors_givenTopicEmpty_thenTopicErrorIsSet() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = ""
        testee.subject = testData.subject
        testee.description = testData.description

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertNotNil(testee.formValidation.topicError)
        XCTAssertEqual(testee.formValidation.topicError, "Select a topic")
        XCTAssertNil(testee.formValidation.subjectError)
        XCTAssertNil(testee.formValidation.descriptionError)
    }

    func test_validationErrors_givenSubjectEmpty_thenSubjectErrorIsSet() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = ""
        testee.description = testData.description

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertNil(testee.formValidation.topicError)
        XCTAssertNotNil(testee.formValidation.subjectError)
        XCTAssertEqual(testee.formValidation.subjectError, "Enter a subject")
        XCTAssertNil(testee.formValidation.descriptionError)
    }

    func test_validationErrors_givenDescriptionEmpty_thenDescriptionErrorIsSet() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = ""

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertNil(testee.formValidation.topicError)
        XCTAssertNil(testee.formValidation.subjectError)
        XCTAssertNotNil(testee.formValidation.descriptionError)
        XCTAssertEqual(testee.formValidation.descriptionError, "Enter a description")
    }

    func test_validationErrors_givenAllFieldsEmpty_thenAllErrorsAreSet() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = ""
        testee.subject = ""
        testee.description = ""

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertNotNil(testee.formValidation.topicError)
        XCTAssertNotNil(testee.formValidation.subjectError)
        XCTAssertNotNil(testee.formValidation.descriptionError)
    }

    func test_validationErrors_givenAllFieldsValid_thenNoErrorsAreSet() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, value: ReportBugResponse(logged: true, id: "123"))

        let viewController = WeakViewController(UIViewController())

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertNil(testee.formValidation.topicError)
        XCTAssertNil(testee.formValidation.subjectError)
        XCTAssertNil(testee.formValidation.descriptionError)
    }

    // MARK: - Submit

    func test_submit_givenRequestSucceeds_whenSubmitCalled_thenViewIsDismissed() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, value: ReportBugResponse(logged: true, id: "123"))

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isShowError, false)
        XCTAssertEqual(router.dismissed, sourceView)
    }

    func test_submit_givenRequestFails_whenSubmitCalled_thenErrorIsShownAndViewNotDismissed() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, error: NSError.internalError())

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isShowError, true)
        XCTAssertNotEqual(testee.errorMessage, "")
        XCTAssertEqual(router.dismissed, nil)
    }

    func test_submit_givenValidInput_whenSubmitCalled_thenLoadingStateIsHandled() {
        // Given
        testee = makeViewModel(scheduler: .immediate)
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, value: ReportBugResponse(logged: true, id: "123"))

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        XCTAssertEqual(testee.state, .data)

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertNotNil(router.dismissed)
    }

    func test_submit_givenRequestSucceeds_whenSubmitCalled_thenDidSubmitBugCallbackIsCalled() {
        // Given
        var callbackCalled = false
        testee = makeViewModel(scheduler: .immediate, didSubmitBug: {
            callbackCalled = true
        })
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, value: ReportBugResponse(logged: true, id: "123"))

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertTrue(callbackCalled)
    }

    func test_submit_givenRequestFails_whenSubmitCalled_thenDidSubmitBugCallbackIsNotCalled() {
        // Given
        var callbackCalled = false
        testee = makeViewModel(scheduler: .immediate, didSubmitBug: {
            callbackCalled = true
        })
        testee.selectedTopic = testData.topic
        testee.subject = testData.subject
        testee.description = testData.description

        let request = ReportBugRequest(
            subject: testData.subject,
            topic: testData.topic,
            description: testData.description,
            email: testData.email,
            url: testData.baseURL
        )
        api.mock(request, error: NSError.internalError())

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertFalse(callbackCalled)
    }

    func test_submit_givenInvalidForm_whenSubmitCalled_thenRequestIsNotMadeAndCallbackIsNotCalled() {
        // Given
        var callbackCalled = false
        testee = makeViewModel(scheduler: .immediate, didSubmitBug: {
            callbackCalled = true
        })

        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.submit(viewController: viewController)

        // Then
        XCTAssertFalse(callbackCalled)
        XCTAssertNil(router.dismissed)
        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Dismiss

    func test_dismiss_givenViewController_whenDismissCalled_thenRouterDismissIsTriggered() {
        // Given
        testee = makeViewModel()
        let sourceView = UIViewController()
        let viewController = WeakViewController(sourceView)

        // When
        testee.dimiss(viewController: viewController)

        // Then
        XCTAssertEqual(router.dismissed, sourceView)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate,
        didSubmitBug: @escaping () -> Void = {}
    ) -> ReportBugViewModel {
        ReportBugViewModel(
            getUserInteractor: getUserInteractor,
            api: api,
            baseURL: testData.baseURL,
            router: router,
            didSubmitBug: didSubmitBug,
            scheduler: scheduler
        )
    }
}
