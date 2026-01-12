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

final class RecipientSelectionViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var testee: RecipientSelectionViewModel!
    private var mockRecipientsSearch: RecipientsSearchInteractorMock!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockRecipientsSearch = RecipientsSearchInteractorMock()
        testScheduler = DispatchQueue.test
        testee = makeViewModel()
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        mockRecipientsSearch = nil
        testScheduler = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeViewModel() -> RecipientSelectionViewModel {
        RecipientSelectionViewModel(
            userID: "test-user-id",
            dispatchQueue: testScheduler.eraseToAnyScheduler(),
            recipientsSearch: mockRecipientsSearch
        )
    }

    // MARK: - Initialization Tests

    func test_init_shouldSetInitialState() {
        // Given & When
        let testee = makeViewModel()

        // Then
        XCTAssertEqual(testee.accessibilityDescription, "")
        XCTAssertTrue(testee.personOptions.isEmpty)
        XCTAssertFalse(testee.isFocused)
        XCTAssertTrue(testee.searchByPersonSelections.isEmpty)
        XCTAssertEqual(testee.searchString, "")
        XCTAssertTrue(testee.recipientIDs.isEmpty)
    }

    func test_init_shouldSubscribeToFocusSubject() {
        // Given
        let testee = makeViewModel()

        // When
        testee.isFocusedSubject.accept(true)

        // Then
        XCTAssertTrue(testee.isFocused)
    }

    func test_init_shouldListenForRecipients() {
        // Given
        let recipients = [
            Recipient(id: "1", name: "John Doe"),
            Recipient(id: "2", name: "Jane Smith")
        ]

        // When
        mockRecipientsSearch.simulateRecipients(recipients)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.personOptions.count, 2)
        XCTAssertEqual(testee.personOptions[0].id, "1")
        XCTAssertEqual(testee.personOptions[0].label, "John Doe")
        XCTAssertEqual(testee.personOptions[1].id, "2")
        XCTAssertEqual(testee.personOptions[1].label, "Jane Smith")
    }

    // MARK: - update(selections:) Tests

    func test_update_shouldUpdateSearchByPersonSelections() {
        // Given
        let selections = [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ]

        // When
        testee.update(selections: selections)

        // Then
        XCTAssertEqual(testee.searchByPersonSelections.count, 1)
        XCTAssertEqual(testee.searchByPersonSelections[0].id, "1")
        XCTAssertEqual(testee.searchByPersonSelections[0].label, "John Doe")
    }

    func test_update_shouldPublishSelections() {
        // Given
        let selections = [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe"),
            HorizonUI.MultiSelect.Option(id: "2", label: "Jane Smith")
        ]

        var publishedSelections: [HorizonUI.MultiSelect.Option]?
        testee.personSelectionPublisher
            .dropFirst() // Skip initial empty value
            .sink { publishedSelections = $0 }
            .store(in: &subscriptions)

        // When
        testee.update(selections: selections)

        // Then
        XCTAssertEqual(publishedSelections?.count, 2)
        XCTAssertEqual(publishedSelections?[0].id, "1")
        XCTAssertEqual(publishedSelections?[1].id, "2")
    }

    func test_update_shouldUpdateAccessibilityDescription_whenSelectionsNotEmpty() {
        // Given
        let selections = [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe"),
            HorizonUI.MultiSelect.Option(id: "2", label: "Jane Smith")
        ]

        // When
        testee.update(selections: selections)

        // Then
        XCTAssertTrue(testee.accessibilityDescription.contains("John Doe"))
        XCTAssertTrue(testee.accessibilityDescription.contains("Jane Smith"))
        XCTAssertTrue(testee.accessibilityDescription.contains("Filtered recipients"))
    }

    func test_update_shouldClearAccessibilityDescription_whenSelectionsEmpty() {
        // Given
        testee.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ])
        XCTAssertFalse(testee.accessibilityDescription.isEmpty)

        // When
        testee.update(selections: [])

        // Then
        XCTAssertEqual(testee.accessibilityDescription, "")
    }

    func test_update_shouldJoinMultipleNamesWithComma() {
        // Given
        let selections = [
            HorizonUI.MultiSelect.Option(id: "1", label: "Alice"),
            HorizonUI.MultiSelect.Option(id: "2", label: "Bob"),
            HorizonUI.MultiSelect.Option(id: "3", label: "Charlie")
        ]

        // When
        testee.update(selections: selections)

        // Then
        XCTAssertTrue(testee.accessibilityDescription.contains("Alice, Bob, Charlie"))
    }

    // MARK: - clearSearch() Tests

    func test_clearSearch_shouldResetSearchString() {
        // Given
        testee.searchString = "test query"

        // When
        testee.clearSearch()

        // Then
        XCTAssertEqual(testee.searchString, "")
    }

    func test_clearSearch_shouldClearPersonOptions() {
        // Given
        mockRecipientsSearch.simulateRecipients([
            Recipient(id: "1", name: "John Doe")
        ])
        testScheduler.advance()
        XCTAssertFalse(testee.personOptions.isEmpty)

        // When
        testee.clearSearch()

        // Then
        XCTAssertTrue(testee.personOptions.isEmpty)
    }

    func test_clearSearch_shouldClearSearchByPersonSelections() {
        // Given
        testee.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ])
        XCTAssertFalse(testee.searchByPersonSelections.isEmpty)

        // When
        testee.clearSearch()

        // Then
        XCTAssertTrue(testee.searchByPersonSelections.isEmpty)
    }

    func test_clearSearch_shouldPublishEmptySelections() {
        // Given
        testee.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ])

        var publishedSelections: [HorizonUI.MultiSelect.Option]?
        testee.personSelectionPublisher
            .dropFirst() // Skip current value
            .sink { publishedSelections = $0 }
            .store(in: &subscriptions)

        // When
        testee.clearSearch()

        // Then
        XCTAssertTrue(publishedSelections?.isEmpty == true)
    }

    // MARK: - setContext(_:) Tests

    func test_setContext_shouldTriggerSearchWithNewContext() {
        // Given
        let newContext = Context.course("course-123")
        testee.searchString = "test"
        testScheduler.advance(by: .milliseconds(250)) // Advance past debounce

        let initialSearchCount = mockRecipientsSearch.searchCallCount

        // When
        testee.setContext(newContext)
        testScheduler.advance(by: .milliseconds(50))

        // Then
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, initialSearchCount + 1)
        XCTAssertEqual(mockRecipientsSearch.lastSearchContext, newContext)
    }

    // MARK: - searchString Tests

    func test_searchString_setter_shouldTriggerSearchAfterDebounce() {
        // Given
        let query = "john"

        // When
        testee.searchString = query
        testScheduler.advance(by: .milliseconds(199)) // Just before debounce

        // Then
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, 0)

        // When - advance past debounce
        testScheduler.advance(by: .milliseconds(1))

        // Then - should have triggered
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, 1)
        XCTAssertEqual(mockRecipientsSearch.lastSearchQuery, query)
    }

    func test_searchString_setter_shouldDebounceMultipleUpdates() {
        // When - rapid updates
        testee.searchString = "j"
        testScheduler.advance(by: .milliseconds(50))

        testee.searchString = "jo"
        testScheduler.advance(by: .milliseconds(50))

        testee.searchString = "joh"
        testScheduler.advance(by: .milliseconds(50))

        testee.searchString = "john"
        testScheduler.advance(by: .milliseconds(200))

        // Then - should only trigger once with final value
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, 1)
        XCTAssertEqual(mockRecipientsSearch.lastSearchQuery, "john")
    }

    func test_searchString_setter_shouldRemoveDuplicates() {
        // When - set same value twice
        testee.searchString = "test"
        testScheduler.advance(by: .milliseconds(250))

        let firstCallCount = mockRecipientsSearch.searchCallCount

        testee.searchString = "test"
        testScheduler.advance(by: .milliseconds(250))

        // Then - should not trigger duplicate search
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, firstCallCount)
    }

    func test_searchString_setter_shouldSearchWithCorrectContext() {
        // Given
        let context = Context.course("course-456")
        testee.setContext(context)

        // When
        testee.searchString = "jane"
        testScheduler.advance(by: .milliseconds(250))

        // Then
        XCTAssertEqual(mockRecipientsSearch.lastSearchContext, context)
    }

    // MARK: - recipientIDs Tests

    func test_recipientIDs_shouldReturnEmptyArray_whenNoSelections() {
        // Given & When
        let ids = testee.recipientIDs

        // Then
        XCTAssertTrue(ids.isEmpty)
    }

    func test_recipientIDs_shouldReturnArrayOfIDs_whenSelectionsExist() {
        // Given
        testee.update(selections: [
            HorizonUI.MultiSelect.Option(id: "123", label: "John"),
            HorizonUI.MultiSelect.Option(id: "456", label: "Jane"),
            HorizonUI.MultiSelect.Option(id: "789", label: "Bob")
        ])

        // When
        let ids = testee.recipientIDs

        // Then
        XCTAssertEqual(ids, ["123", "456", "789"])
    }

    // MARK: - isFocusedSubject Tests

    func test_isFocusedSubject_shouldUpdateIsFocusedProperty() {
        // Given
        XCTAssertFalse(testee.isFocused)

        // When
        testee.isFocusedSubject.accept(true)

        // Then
        XCTAssertTrue(testee.isFocused)

        // When
        testee.isFocusedSubject.accept(false)

        // Then
        XCTAssertFalse(testee.isFocused)
    }

    // MARK: - Recipients Subscription Tests

    func test_listenForRecipients_shouldUpdatePersonOptions_whenRecipientsChange() {
        // Given
        let initialRecipients = [
            Recipient(id: "1", name: "Alice")
        ]
        mockRecipientsSearch.simulateRecipients(initialRecipients)
        testScheduler.advance()

        XCTAssertEqual(testee.personOptions.count, 1)

        // When
        let newRecipients = [
            Recipient(id: "2", name: "Bob"),
            Recipient(id: "3", name: "Charlie")
        ]
        mockRecipientsSearch.simulateRecipients(newRecipients)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.personOptions.count, 2)
        XCTAssertEqual(testee.personOptions[0].id, "2")
        XCTAssertEqual(testee.personOptions[0].label, "Bob")
        XCTAssertEqual(testee.personOptions[1].id, "3")
        XCTAssertEqual(testee.personOptions[1].label, "Charlie")
    }

    func test_listenForRecipients_shouldMapRecipientsToOptions() {
        // Given
        let recipients = [
            Recipient(id: "user-1", name: "Test User One"),
            Recipient(id: "user-2", name: "Test User Two")
        ]

        // When
        mockRecipientsSearch.simulateRecipients(recipients)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.personOptions.count, 2)

        let option1 = testee.personOptions[0]
        XCTAssertEqual(option1.id, "user-1")
        XCTAssertEqual(option1.label, "Test User One")

        let option2 = testee.personOptions[1]
        XCTAssertEqual(option2.id, "user-2")
        XCTAssertEqual(option2.label, "Test User Two")
    }

    // MARK: - Integration Tests

    func test_searchWorkflow_shouldWorkEndToEnd() {
        // Given
        let query = "test query"
        let recipients = [
            Recipient(id: "1", name: "Test User")
        ]

        // When - user types search query
        testee.searchString = query
        testScheduler.advance(by: .milliseconds(250))

        // Then - search should be triggered
        XCTAssertEqual(mockRecipientsSearch.searchCallCount, 1)
        XCTAssertEqual(mockRecipientsSearch.lastSearchQuery, query)

        // When - recipients are returned
        mockRecipientsSearch.simulateRecipients(recipients)
        testScheduler.advance()

        // Then - person options should be updated
        XCTAssertEqual(testee.personOptions.count, 1)
        XCTAssertEqual(testee.personOptions[0].label, "Test User")

        // When - user selects a person
        testee.update(selections: [testee.personOptions[0]])

        // Then - selections should be updated
        XCTAssertEqual(testee.searchByPersonSelections.count, 1)
        XCTAssertEqual(testee.recipientIDs, ["1"])
        XCTAssertTrue(testee.accessibilityDescription.contains("Test User"))
    }

    func test_clearSearchWorkflow_shouldResetAllState() {
        // Given - set up some state
        testee.searchString = "test"
        testScheduler.advance(by: .milliseconds(250))

        mockRecipientsSearch.simulateRecipients([
            Recipient(id: "1", name: "User")
        ])
        testScheduler.advance()

        testee.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "User")
        ])

        XCTAssertFalse(testee.searchString.isEmpty)
        XCTAssertFalse(testee.personOptions.isEmpty)
        XCTAssertFalse(testee.searchByPersonSelections.isEmpty)

        // When
        testee.clearSearch()

        // Then - everything should be reset
        XCTAssertEqual(testee.searchString, "")
        XCTAssertTrue(testee.personOptions.isEmpty)
        XCTAssertTrue(testee.searchByPersonSelections.isEmpty)
        XCTAssertTrue(testee.recipientIDs.isEmpty)
    }
}
