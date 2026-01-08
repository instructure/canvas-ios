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

final class HInboxViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var viewModel: HInboxViewModel!
    private var mockInboxMessageInteractor: InboxMessageInteractorMock!
    private var mockAnnouncementInteractor: AnnouncementInteractorMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockInboxMessageInteractor = InboxMessageInteractorMock()
        mockAnnouncementInteractor = AnnouncementInteractorMock()
        viewModel = makeViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockInboxMessageInteractor = nil
        mockAnnouncementInteractor = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeViewModel() -> HInboxViewModel {
        HInboxViewModel(
            userID: "test-user-id",
            router: router,
            inboxMessageInteractor: mockInboxMessageInteractor,
            announcementInteractor: mockAnnouncementInteractor
        )
    }

    func test_shouldIncludeAnnouncements_whenFilterIsAll_andNoPeopleFilter_shouldReturnTrue() {
        // Given
        let filter = InboxFilterOption.all
        let hasPeopleFilter = false

        // When
        let result = viewModel.shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )
        // Then
        XCTAssertTrue(result)
    }

    func test_shouldIncludeAnnouncements_whenFilterIsAnnouncements_andNoPeopleFilter_shouldReturnTrue() {
        // Given
        let filter = InboxFilterOption.announcements
        let hasPeopleFilter = false

        // When
        let result = viewModel.shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_shouldIncludeAnnouncements_whenFilterIsUnread_andNoPeopleFilter_shouldReturnTrue() {
        // Given
        let filter = InboxFilterOption.unread
        let hasPeopleFilter = false

        // When
        let result = viewModel.shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_shouldIncludeAnnouncements_whenFilterIsSent_andNoPeopleFilter_shouldReturnFalse() {
        // Given
        let filter = InboxFilterOption.sent
        let hasPeopleFilter = false

        // When
        let result = viewModel.shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )

        // Then
        XCTAssertFalse(result)
    }

    func test_shouldIncludeAnnouncements_whenFilterIsAll_andHasPeopleFilter_shouldReturnFalse() {
        // Given
        let filter = InboxFilterOption.all
        let hasPeopleFilter = true

        // When
        let result = viewModel.shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )

        // Then
        XCTAssertFalse(result)
    }

    func test_shouldIncludeAnnouncements_whenFilterIsAnnouncements_andHasPeopleFilter_shouldReturnFalse() {
        // Given
        let filter = InboxFilterOption.announcements
        let hasPeopleFilter = true

        // When
        let result = viewModel.shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )

        // Then
        XCTAssertFalse(result)
    }

    func test_filterAnnouncementsByReadStatus_whenFilterIsAll_shouldReturnAllAnnouncements() {
        // Given
        let announcements = [
            AnnouncementModel.make(id: "1", isRead: false),
            AnnouncementModel.make(id: "2", isRead: true),
            AnnouncementModel.make(id: "3", isRead: false)
        ]
        let filter = InboxFilterOption.all

        // When
        let result = viewModel.filterAnnouncementsByReadStatus(announcements, filter: filter)

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, "1")
        XCTAssertEqual(result[1].id, "2")
        XCTAssertEqual(result[2].id, "3")
    }

    func test_filterAnnouncementsByReadStatus_whenFilterIsUnread_shouldReturnOnlyUnread() {
        // Given
        let announcements = [
            AnnouncementModel.make(id: "1", isRead: false),
            AnnouncementModel.make(id: "2", isRead: true),
            AnnouncementModel.make(id: "3", isRead: false)
        ]
        let filter = InboxFilterOption.unread

        // When
        let result = viewModel.filterAnnouncementsByReadStatus(announcements, filter: filter)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "1")
        XCTAssertEqual(result[1].id, "3")
        XCTAssertTrue(result.allSatisfy { !$0.isRead })
    }

    func test_filterAnnouncementsByReadStatus_whenFilterIsUnread_andAllAreRead_shouldReturnEmpty() {
        // Given
        let announcements = [
            AnnouncementModel.make(id: "1", isRead: true),
            AnnouncementModel.make(id: "2", isRead: true)
        ]
        let filter = InboxFilterOption.unread

        // When
        let result = viewModel.filterAnnouncementsByReadStatus(announcements, filter: filter)

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_filterAnnouncementsByReadStatus_whenFilterIsSent_shouldReturnAllAnnouncements() {
        // Given
        let announcements = [
            AnnouncementModel.make(id: "1", isRead: false),
            AnnouncementModel.make(id: "2", isRead: true)
        ]
        let filter = InboxFilterOption.sent

        // When
        let result = viewModel.filterAnnouncementsByReadStatus(announcements, filter: filter)

        // Then
        XCTAssertEqual(result.count, 2)
    }

    func test_messageMatchesPeopleFilter_whenSelectedPeopleIsEmpty_shouldReturnTrue() {
        // Given
        let participantName = "John Doe"
        let selectedPeople: [HorizonUI.MultiSelect.Option] = []

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_messageMatchesPeopleFilter_whenNameMatchesExactly_shouldReturnTrue() {
        // Given
        let participantName = "John Doe"
        let selectedPeople = [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ]

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_messageMatchesPeopleFilter_whenNameContainsPersonLabel_shouldReturnTrue() {
        // Given
        let participantName = "John Doe, Jane Smith"
        let selectedPeople = [
            HorizonUI.MultiSelect.Option(id: "1", label: "John")
        ]

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_messageMatchesPeopleFilter_whenNameMatchesCaseInsensitive_shouldReturnTrue() {
        // Given
        let participantName = "JOHN DOE"
        let selectedPeople = [
            HorizonUI.MultiSelect.Option(id: "1", label: "john doe")
        ]

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_messageMatchesPeopleFilter_whenNameDoesNotMatch_shouldReturnFalse() {
        // Given
        let participantName = "John Doe"
        let selectedPeople = [
            HorizonUI.MultiSelect.Option(id: "1", label: "Jane Smith")
        ]

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertFalse(result)
    }

    func test_messageMatchesPeopleFilter_whenMultiplePeople_andOneMatches_shouldReturnTrue() {
        // Given
        let participantName = "John Doe"
        let selectedPeople = [
            HorizonUI.MultiSelect.Option(id: "1", label: "Jane Smith"),
            HorizonUI.MultiSelect.Option(id: "2", label: "John"),
            HorizonUI.MultiSelect.Option(id: "3", label: "Bob Wilson")
        ]

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertTrue(result)
    }

    func test_messageMatchesPeopleFilter_whenPartialMatch_shouldReturnTrue() {
        // Given
        let participantName = "John Doe"
        let selectedPeople = [
            HorizonUI.MultiSelect.Option(id: "1", label: "Doe")
        ]

        // When
        let result = viewModel.messageMatchesPeopleFilter(
            participantName: participantName,
            selectedPeople: selectedPeople
        )

        // Then
        XCTAssertTrue(result)
    }

    // MARK: - Integration Tests

    func test_init_shouldSetContextOnInboxMessageInteractor() {
        // Given & When
        _ = makeViewModel()

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.setContextCallCount, 2)
        XCTAssertEqual(mockInboxMessageInteractor.lastSetContext, .user("test-user-id"))
    }

    func test_filterTitle_setter_shouldAcceptNewFilterAndRefresh() {
        // Given
        let newFilterTitle = InboxFilterOption.unread.title

        // When
        viewModel.filterTitle = newFilterTitle

        // Then
        XCTAssertEqual(viewModel.filterTitle, newFilterTitle)
        XCTAssertEqual(mockInboxMessageInteractor.refreshCallCount, 1)
    }

    func test_filterTitle_setter_whenInvalidTitle_shouldDefaultToAll() {
        // Given
        let initialRefreshCount = mockInboxMessageInteractor.refreshCallCount

        // When
        viewModel.filterTitle = "Invalid Filter"

        // Then
        XCTAssertEqual(viewModel.filterTitle, InboxFilterOption.all.title)
        XCTAssertEqual(mockInboxMessageInteractor.refreshCallCount, initialRefreshCount + 1)
    }

    func test_loadMore_whenNoNextPage_shouldNotLoadNextPage() {
        // Given
        let message = InboxMessageModel.make()
        mockInboxMessageInteractor.hasNextPage.send(false)
        mockInboxMessageInteractor.state.send(.data)

        // When
        viewModel.loadMore(message: message)

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.loadNextPageCallCount, 0)
    }

    func test_loadMore_whenIsLoading_shouldNotLoadNextPage() {
        // Given
        let message = InboxMessageModel.make()
        mockInboxMessageInteractor.hasNextPage.send(true)
        mockInboxMessageInteractor.state.send(.loading)

        // When
        viewModel.loadMore(message: message)

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.loadNextPageCallCount, 0)
    }

    func test_loadMore_whenHasNextPage_andNotLoading_andIsLastMessage_shouldCallLoadNextPage() {
        // Given
        mockAnnouncementInteractor = AnnouncementInteractorMock(shouldReturnError: true)
        mockInboxMessageInteractor = InboxMessageInteractorMock()
        viewModel = .init(
            userID: "userID-1",
            router: router,
            inboxMessageInteractor: mockInboxMessageInteractor,
            announcementInteractor: mockAnnouncementInteractor
        )
        mockInboxMessageInteractor.hasNextPage.send(true)
        mockInboxMessageInteractor.state.send(.data)

        let entity = InboxMessageListItem.make(id: "1", in: databaseClient)
        let message = InboxMessageModel(announcement: nil, entity: entity)

        mockInboxMessageInteractor.messages.send([entity])

        // When
        viewModel.loadMore(message: message)

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.loadNextPageCallCount, 1)
    }

    func test_loadMore_whenNotLastMessage_shouldNotCallLoadNextPage() {
        // Given
        mockInboxMessageInteractor.hasNextPage.send(true)
        mockInboxMessageInteractor.state.send(.data)

        let entity1 = InboxMessageListItem.make(id: "1", in: databaseClient)
        let entity2 = InboxMessageListItem.make(id: "2", in: databaseClient)
        let message1 = InboxMessageModel(announcement: nil, entity: entity1)

        // Simulate that messageRows contains both messages
        mockInboxMessageInteractor.messages.send([entity1, entity2])

        // When
        viewModel.loadMore(message: message1)

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.loadNextPageCallCount, 0)
    }

    func test_refresh_shouldCallRefreshOnBothInteractors() {
        // Given
        var endRefreshingCalled = false
        let endRefreshing: () -> Void = {
            endRefreshingCalled = true
        }

        let initialRefreshCount = mockInboxMessageInteractor.refreshCallCount

        // When
        viewModel.refresh(endRefreshing: endRefreshing)
        // Then
        XCTAssertEqual(mockInboxMessageInteractor.refreshCallCount, initialRefreshCount + 1)
        XCTAssertTrue(endRefreshingCalled)
    }

    func test_refresh_shouldFetchAnnouncementsIgnoringCache() {
        // Given
        let customAnnouncements = [
            AnnouncementModel.make(id: "fresh-1", title: "Fresh Announcement")
        ]
        mockAnnouncementInteractor.mockedAnnouncements = customAnnouncements

        var endRefreshingCalled = false
        let endRefreshing: () -> Void = {
            endRefreshingCalled = true
        }

        // When
        viewModel.refresh(endRefreshing: endRefreshing)

        // Then
        XCTAssertTrue(endRefreshingCalled)
    }

    func test_handleFilterFocusChange_whenMessagesFilterGainsFocus_andPeopleSearchIsFocused_shouldUnfocusPeopleSearch() {
        // Given
        viewModel.peopleSelectionViewModel.isFocusedSubject.accept(true)
        XCTAssertTrue(viewModel.peopleSelectionViewModel.isFocusedSubject.value)

        // When
        viewModel.isMessagesFilterFocused = true

        // Then
        XCTAssertFalse(viewModel.peopleSelectionViewModel.isFocusedSubject.value)
    }

    func test_handleFilterFocusChange_whenMessagesFilterLosesFocus_shouldNotAffectPeopleSearch() {
        // Given
        viewModel.peopleSelectionViewModel.isFocusedSubject.accept(true)
        viewModel.isMessagesFilterFocused = true

        // Reset people search focus
        viewModel.peopleSelectionViewModel.isFocusedSubject.accept(true)

        // When - losing focus on messages filter
        viewModel.isMessagesFilterFocused = false
        // Then
        XCTAssertTrue(viewModel.peopleSelectionViewModel.isFocusedSubject.value)
    }

    func test_peopleSearchFocus_whenGainsFocus_andMessagesFilterIsFocused_shouldUnfocusMessagesFilter() {
        // Given
        viewModel.isMessagesFilterFocused = true

        // When
        viewModel.peopleSelectionViewModel.isFocusedSubject.accept(true)

        // Then
        XCTAssertFalse(viewModel.isMessagesFilterFocused)
    }

    func test_handleFilterChange_whenFilterChanges_shouldUpdateInteractorScope() {
        // Given
        let initialSetScopeCount = mockInboxMessageInteractor.setScopeCallCount

        // When
        viewModel.filterTitle = InboxFilterOption.unread.title

        // Then
        XCTAssertEqual(mockInboxMessageInteractor.setScopeCallCount, initialSetScopeCount + 1)
        XCTAssertEqual(mockInboxMessageInteractor.lastSetScope, .unread)
    }

    func test_handleFilterChange_whenFilterIsAnnouncements_shouldClearPeopleSearch() {
        // Given
        viewModel.peopleSelectionViewModel.update(selections: [
            HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")
        ])
        XCTAssertFalse(viewModel.peopleSelectionViewModel.searchByPersonSelections.isEmpty)

        // When
        viewModel.filterTitle = InboxFilterOption.announcements.title

        // Then
        XCTAssertTrue(viewModel.peopleSelectionViewModel.searchByPersonSelections.isEmpty)
    }

    func test_handleFilterChange_whenFilterIsNotAnnouncements_shouldNotClearPeopleSearch() {
        // Given
        let selections = [HorizonUI.MultiSelect.Option(id: "1", label: "John Doe")]
        viewModel.peopleSelectionViewModel.update(selections: selections)

        // When
        viewModel.filterTitle = InboxFilterOption.unread.title

        // Then
        XCTAssertFalse(viewModel.peopleSelectionViewModel.searchByPersonSelections.isEmpty)
    }

    func test_goBack_shouldCallRouterPop() {
        // Given
        let weakVC = WeakViewController(UIViewController())

        // When
        viewModel.goBack(weakVC)

        // Then
        wait(for: [router.popExpectation], timeout: 0.1)
        XCTAssertNotNil(router.popped)
    }

    func test_goToComposeMessage_shouldRouteToCreateConversation() {
        // Given
        let weakVC = WeakViewController(UIViewController())

        // When
        viewModel.goToComposeMessage(weakVC)

        // Then
        XCTAssertTrue(router.lastRoutedTo(.parse("/conversations/create")))
    }

    func test_viewMessage_withMessageID_shouldRouteToConversation() {
        // Given
        let weakVC = WeakViewController(UIViewController())
        let messageID = "123"

        // When
        viewModel.viewMessage(
            announcement: nil,
            messageID: messageID,
            viewController: weakVC
        )

        // Then
        XCTAssertTrue(router.lastRoutedTo(.parse("/conversations/123")))
    }

    func test_viewMessage_withAnnouncement_shouldRouteToAnnouncements() {
        // Given
        let weakVC = WeakViewController(UIViewController())
        let announcement = AnnouncementModel.make(id: "456")

        // When
        viewModel.viewMessage(
            announcement: announcement,
            messageID: nil,
            viewController: weakVC
        )

        // Then
        XCTAssertTrue(router.lastRoutedTo(.parse("/announcements")))
    }

    func test_isSearchDisabled_whenFilterIsAnnouncements_shouldBeTrue() {
        // Given & When
        viewModel.filterTitle = InboxFilterOption.announcements.title

        // Then
        XCTAssertTrue(viewModel.isSearchDisabled)
    }

    func test_isSearchDisabled_whenFilterIsNotAnnouncements_shouldBeFalse() {
        // Given & When
        viewModel.filterTitle = InboxFilterOption.all.title

        // Then
        XCTAssertFalse(viewModel.isSearchDisabled)
    }
}

// MARK: - Test Helpers

extension AnnouncementModel {
    static func make(
        id: String = "test-id",
        title: String = "Test Announcement",
        content: String = "Test content",
        courseID: String? = "course-1",
        courseName: String? = "Test Course",
        date: Date? = Date(),
        isRead: Bool = false,
        isGlobal: Bool = false
    ) -> AnnouncementModel {
        AnnouncementModel(
            id: id,
            title: title,
            content: content,
            courseID: courseID,
            courseName: courseName,
            date: date,
            isRead: isRead,
            isGlobal: isGlobal
        )
    }
}

extension InboxMessageModel {
    static func make(
        id: String = "test-id",
        announcement: AnnouncementModel? = nil,
        entity: InboxMessageListItem? = nil
    ) -> InboxMessageModel {
        if let announcement {
            return InboxMessageModel(
                announcement: announcement,
                entity: nil
            )
        }
        return InboxMessageModel(
            announcement: nil,
            date: nil,
            dateString: "",
            isNew: true,
            messageListItemID: "test-id",
            isAnnouncement: false,
            subtitle: "Test Participant",
            messageTitle: "Test Message"
        )
    }
}
