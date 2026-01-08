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

final class RecipientsSearchInteractorTests: HorizonTestCase {

    // MARK: - Properties

    private var testee: RecipientsSearchInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        testee = RecipientsSearchInteractorLive(
            currentUserID: "current-user-123",
            api: api
        )
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        API.resetMocks(useMocks: false)
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeAPISearchRecipient(
        id: String,
        name: String,
        type: APISearchRecipientContext = .user
    ) -> APISearchRecipient {
        APISearchRecipient.make(
            id: ID(id),
            name: name,
            type: type
        )
    }

    // MARK: - Initial State Tests

    func test_init_shouldSetInitialLoadingToFalse() {
        XCTAssertFalse(testee.loading.value)
    }

    func test_init_shouldSetInitialRecipientsToEmpty() {
        XCTAssertTrue(testee.recipients.value.isEmpty)
    }

    // MARK: - Search Tests

    func test_search_shouldSetLoadingToTrue() {
        let expectation = XCTestExpectation(description: "Loading state updated")

        testee.loading
            .dropFirst()
            .sink { isLoading in
                if isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: []
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)
    }

    func test_search_shouldSetLoadingToFalse_afterCompletion() {
        let expectation = XCTestExpectation(description: "Loading completed")

        var loadingStates: [Bool] = []
        testee.loading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: []
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(loadingStates[0], false)
        XCTAssertEqual(loadingStates[1], true)
        XCTAssertEqual(loadingStates[2], false)
    }

    func test_search_shouldReturnRecipients() {
        let expectation = XCTestExpectation(description: "Recipients received")

        testee.recipients
            .dropFirst()
            .sink { recipients in
                if !recipients.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        let mockRecipients = [
            makeAPISearchRecipient(id: "user-1", name: "John Doe"),
            makeAPISearchRecipient(id: "user-2", name: "Jane Smith")
        ]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "john",
                perPage: 10
            ),
            value: mockRecipients
        )

        testee.search(with: "john", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(testee.recipients.value.count, 2)
        XCTAssertEqual(testee.recipients.value[0].id, "user-1")
        XCTAssertEqual(testee.recipients.value[0].name, "John Doe")
        XCTAssertEqual(testee.recipients.value[1].id, "user-2")
        XCTAssertEqual(testee.recipients.value[1].name, "Jane Smith")
    }

    func test_search_shouldFilterOutCurrentUser() {
        let expectation = XCTestExpectation(description: "Recipients filtered")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        let mockRecipients = [
            makeAPISearchRecipient(id: "user-1", name: "John Doe"),
            makeAPISearchRecipient(id: "current-user-123", name: "Current User"),
            makeAPISearchRecipient(id: "user-2", name: "Jane Smith")
        ]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: mockRecipients
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(testee.recipients.value.count, 2)
        XCTAssertFalse(testee.recipients.value.contains { $0.id == "current-user-123" })
        XCTAssertTrue(testee.recipients.value.contains { $0.id == "user-1" })
        XCTAssertTrue(testee.recipients.value.contains { $0.id == "user-2" })
    }

    func test_search_shouldHandleEmptyResults() {
        let expectation = XCTestExpectation(description: "Empty results handled")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "nonexistent",
                perPage: 10
            ),
            value: []
        )

        testee.search(with: "nonexistent", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(testee.recipients.value.isEmpty)
        XCTAssertFalse(testee.loading.value)
    }

    func test_search_shouldHandleNilResponse() {
        let expectation = XCTestExpectation(description: "Nil response handled")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: nil
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(testee.recipients.value.isEmpty)
    }

    func test_search_shouldCancelPreviousTask_whenNewSearchStarts() {
        let expectation = XCTestExpectation(description: "Previous task cancelled")

        let mockRecipients1 = [makeAPISearchRecipient(id: "user-1", name: "First")]
        let mockRecipients2 = [makeAPISearchRecipient(id: "user-2", name: "Second")]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "first",
                perPage: 10
            ),
            value: mockRecipients1
        ).suspend()

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "second",
                perPage: 10
            ),
            value: mockRecipients2
        )

        testee.search(with: "first", using: .course("course-123"))
        testee.search(with: "second", using: .course("course-123"))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(testee.recipients.value.count, 1)
        XCTAssertEqual(testee.recipients.value[0].id, "user-2")
        XCTAssertEqual(testee.recipients.value[0].name, "Second")
    }

    func test_search_shouldWorkWithDifferentContexts() {
        let courseExpectation = XCTestExpectation(description: "Course recipients received")
        let groupExpectation = XCTestExpectation(description: "Group recipients received")

        let courseRecipients = [makeAPISearchRecipient(id: "user-1", name: "Course User")]
        let groupRecipients = [makeAPISearchRecipient(id: "user-2", name: "Group User")]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: courseRecipients
        )

        api.mock(
            GetSearchRecipientsRequest(
                context: .group("group-456"),
                search: "test",
                perPage: 10
            ),
            value: groupRecipients
        )

        var recipientUpdates: [[Horizon.Recipient]] = []

        testee.recipients
            .dropFirst()
            .sink { recipients in
                recipientUpdates.append(recipients)
                if recipientUpdates.count == 1 {
                    courseExpectation.fulfill()
                } else if recipientUpdates.count == 2 {
                    groupExpectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        testee.search(with: "test", using: .course("course-123"))
        wait(for: [courseExpectation], timeout: 1.0)
        XCTAssertEqual(recipientUpdates[0][0].id, "user-1")

        testee.search(with: "test", using: .group("group-456"))
        wait(for: [groupExpectation], timeout: 1.0)
        XCTAssertEqual(recipientUpdates[1][0].id, "user-2")
    }

    func test_search_shouldHandleMultipleSequentialSearches() {
        let firstExpectation = XCTestExpectation(description: "First search")
        let secondExpectation = XCTestExpectation(description: "Second search")
        let thirdExpectation = XCTestExpectation(description: "Third search")

        let recipients1 = [makeAPISearchRecipient(id: "user-1", name: "First")]
        let recipients2 = [makeAPISearchRecipient(id: "user-2", name: "Second")]
        let recipients3 = [makeAPISearchRecipient(id: "user-3", name: "Third")]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "first",
                perPage: 10
            ),
            value: recipients1
        )

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "second",
                perPage: 10
            ),
            value: recipients2
        )

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "third",
                perPage: 10
            ),
            value: recipients3
        )

        var recipientUpdates: [[Horizon.Recipient]] = []

        testee.recipients
            .dropFirst()
            .sink { recipients in
                recipientUpdates.append(recipients)
                switch recipientUpdates.count {
                case 1: firstExpectation.fulfill()
                case 2: secondExpectation.fulfill()
                case 3: thirdExpectation.fulfill()
                default: break
                }
            }
            .store(in: &subscriptions)

        testee.search(with: "first", using: .course("course-123"))
        wait(for: [firstExpectation], timeout: 1.0)
        XCTAssertEqual(recipientUpdates[0][0].id, "user-1")

        testee.search(with: "second", using: .course("course-123"))
        wait(for: [secondExpectation], timeout: 1.0)
        XCTAssertEqual(recipientUpdates[1][0].id, "user-2")

        testee.search(with: "third", using: .course("course-123"))
        wait(for: [thirdExpectation], timeout: 1.0)
        XCTAssertEqual(recipientUpdates[2][0].id, "user-3")
    }

    func test_search_shouldHandleEmptySearchQuery() {
        let expectation = XCTestExpectation(description: "Empty query handled")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "",
                perPage: 10
            ),
            value: []
        )

        testee.search(with: "", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(testee.recipients.value.isEmpty)
    }

    func test_search_shouldMapIDCorrectly() {
        let expectation = XCTestExpectation(description: "ID mapping")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        let mockRecipients = [
            makeAPISearchRecipient(id: "12345", name: "Test User")
        ]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: mockRecipients
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(testee.recipients.value[0].id, "12345")
    }

    func test_search_shouldHandleOnlyCurrentUserInResults() {
        let expectation = XCTestExpectation(description: "Only current user filtered")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        let mockRecipients = [
            makeAPISearchRecipient(id: "current-user-123", name: "Current User")
        ]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "current",
                perPage: 10
            ),
            value: mockRecipients
        )

        testee.search(with: "current", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(testee.recipients.value.isEmpty)
    }

    func test_search_shouldHandleManyResults() {
        let expectation = XCTestExpectation(description: "Many results handled")

        testee.recipients
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        let mockRecipients = (1...20).map { index in
            makeAPISearchRecipient(id: "user-\(index)", name: "User \(index)")
        }

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "user",
                perPage: 10
            ),
            value: mockRecipients
        )

        testee.search(with: "user", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(testee.recipients.value.count, 20)
    }

    // MARK: - Publishers Tests

    func test_loading_shouldBePublisher() {
        let expectation = XCTestExpectation(description: "Loading publisher")

        var receivedValues: [Bool] = []

        testee.loading
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: []
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedValues, [false, true, false])
    }

    func test_recipients_shouldBePublisher() {
        let expectation = XCTestExpectation(description: "Recipients publisher")

        var receivedCount = 0

        testee.recipients
            .sink { _ in
                receivedCount += 1
                if receivedCount == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        let mockRecipients = [makeAPISearchRecipient(id: "user-1", name: "Test")]

        api.mock(
            GetSearchRecipientsRequest(
                context: .course("course-123"),
                search: "test",
                perPage: 10
            ),
            value: mockRecipients
        )

        testee.search(with: "test", using: .course("course-123"))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedCount, 2)
    }
}
