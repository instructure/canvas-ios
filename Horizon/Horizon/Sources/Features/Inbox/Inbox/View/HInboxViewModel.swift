//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Combine
import CombineExt
import Observation
import Foundation
import HorizonUI

@Observable
final class HInboxViewModel {
    // MARK: - Outputs

    /// Sets the current filter and triggers a refresh of messages.
    /// Note: Setting this property has the side effect of calling `inboxMessageInteractor.refresh()`
    var filterTitle: String {
        get { filterSubject.value.title }
        set {
            filterSubject.accept(InboxFilterOption.allCases.first { $0.title == newValue } ?? .all)
            _ = inboxMessageInteractor.refresh()
        }
    }

    var isMessagesFilterFocused: Bool = false {
        didSet {
            handleFilterFocusChange()
        }
    }
    var isSearchDisabled: Bool { filterSubject.value == .announcements }
    private(set) var messageRows: [InboxMessageModel] = []
    private(set) var peopleSelectionViewModel: RecipientSelectionViewModel
    private(set) var screenState: InstUI.ScreenState = .loading

    // MARK: - Private

    private var filterSubject: CurrentValueRelay<InboxFilterOption> = CurrentValueRelay(InboxFilterOption.all)
    private var subscriptions = Set<AnyCancellable>()
    private var announcementsPublisher = PassthroughSubject<[AnnouncementModel], Never>()

    // MARK: - Dependencies

    private let announcementInteractor: AnnouncementInteractor
    private let inboxMessageInteractor: InboxMessageInteractor
    private let router: Router

    // MARK: - Init

    init(
        userID: String,
        router: Router,
        inboxMessageInteractor: InboxMessageInteractor,
        announcementInteractor: AnnouncementInteractor
    ) {
        self.router = router
        self.inboxMessageInteractor = inboxMessageInteractor
        self.announcementInteractor = announcementInteractor
        self.peopleSelectionViewModel = .init(userID: userID)

        _ = inboxMessageInteractor.setContext(.user(userID))

        listenForMessagesAndAnnouncements()

        // When the message filter type changes, make the necessary updates.
        filterSubject
            .sink { [weak self] filterOption in
                self?.handleFilterChange(filterOption)
            }
            .store(in: &subscriptions)

        // close the messages filter when the people selection view model is focused
        peopleSelectionViewModel.isFocusedSubject
            .sink { [weak self] isFocused in
                if isFocused && self?.isMessagesFilterFocused == true {
                    self?.isMessagesFilterFocused = false
                }
            }
            .store(in: &subscriptions)
        fetchAnnouncements()
    }

    // MARK: - Actions Functions

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func goToComposeMessage(_ viewController: WeakViewController) {
        router.route(to: "/conversations/create", from: viewController)
    }

    func loadMore(message: InboxMessageModel) {
        let isLoadingMore = inboxMessageInteractor.state.value == .loading
        let hasNextPage = inboxMessageInteractor.hasNextPage.value
        guard hasNextPage, !isLoadingMore, message == messageRows.last else { return }
        inboxMessageInteractor
            .loadNextPage()
            .sink()
            .store(in: &subscriptions)
    }

    func refresh(endRefreshing: @escaping () -> Void) {
        inboxMessageInteractor
            .refresh()
            .zip(announcementInteractor.getAllAnnouncements(ignoreCache: true))
            .sink { [weak self] _, announcements in
                self?.announcementsPublisher.send(announcements)
                endRefreshing()
            }
            .store(in: &subscriptions)
    }

    func viewMessage(
        announcement: AnnouncementModel?,
        messageID: String?,
        viewController: WeakViewController
    ) {
        if let messageID {
            router.route(
                to: "/conversations/\(messageID)",
                from: viewController
            )
        }
        if let announcement {
            router.route(
                to: "/announcements",
                userInfo: ["announcement": announcement],
                from: viewController
            )
        }
    }

    // MARK: - Business Logic Helpers

    /// Determines whether announcements should be included based on filter and people selection
    func shouldIncludeAnnouncements(
        filter: InboxFilterOption,
        hasPeopleFilter: Bool
    ) -> Bool {
        let isAnnouncementFilter = filter != .sent
        return isAnnouncementFilter && !hasPeopleFilter
    }

    /// Filters announcements by read status when filter is .unread
    func filterAnnouncementsByReadStatus(
        _ announcements: [AnnouncementModel],
        filter: InboxFilterOption
    ) -> [AnnouncementModel] {
        guard filter == .unread else { return announcements }
        return announcements.filter { !$0.isRead }
    }

    /// Matches message participant name against selected people using case-insensitive substring matching
    func messageMatchesPeopleFilter(
        participantName: String,
        selectedPeople: [HorizonUI.MultiSelect.Option]
    ) -> Bool {
        guard !selectedPeople.isEmpty else { return true }

        let lowercasedName = participantName.lowercased()
        return selectedPeople.contains { person in
            lowercasedName.contains(person.label.lowercased())
        }
    }

    /// Filters messages by person and transforms to InboxMessageModel
    private func filterMessages(
        _ messages: [InboxMessageListItem]
    ) -> [InboxMessageModel] {
        return messages
            .filter(filterByPerson)
            .map(\.messageModel)
    }

    /// Merges messages and announcements based on current filter
    private func mergeMessagesAndAnnouncements(
        messages: [InboxMessageListItem],
        announcements: [AnnouncementModel],
        filter: InboxFilterOption
    ) -> [InboxMessageModel] {
        guard filter.inboxMessageInteractorScope != nil else {
            return announcements.map(\.messageModel)
        }

        let filteredMessages = filterMessages(messages)
        return addAnnouncements(to: filteredMessages, announcements: announcements)
    }

    // MARK: - Private Functions

    private func addAnnouncements(to messageRows: [InboxMessageModel], announcements: [AnnouncementModel]) -> [InboxMessageModel] {
        let filter = filterSubject.value
        let hasPeopleFilter = !peopleSelectionViewModel.searchByPersonSelections.isEmpty

        let shouldInclude = shouldIncludeAnnouncements(
            filter: filter,
            hasPeopleFilter: hasPeopleFilter
        )

        let filteredAnnouncements = shouldInclude
            ? filterAnnouncementsByReadStatus(announcements, filter: filter)
            : []

        let announcementRows = filteredAnnouncements.map(\.messageModel)

        return (messageRows + announcementRows)
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    private func fetchAnnouncements(ignoreCache: Bool = false) {
        announcementInteractor
            .getAllAnnouncements(ignoreCache: ignoreCache)
            .sink { [weak self] announcements in
                self?.announcementsPublisher.send(announcements)
            }
            .store(in: &subscriptions)
    }

    private func listenForMessagesAndAnnouncements() {
        Publishers.CombineLatest4(
            inboxMessageInteractor.messages,
            announcementsPublisher,
            filterSubject,
            peopleSelectionViewModel.personSelectionPublisher
        )
        .map { [weak self] messages, announcements, filter, _ -> [InboxMessageModel] in
            guard let self else { return [] }
            return self.mergeMessagesAndAnnouncements(
                messages: messages,
                announcements: announcements,
                filter: filter
            )
        }
        .sink { [weak self] mergedMessages in
            guard let self else { return }
            self.messageRows = mergedMessages
            self.screenState = .data
        }
        .store(in: &subscriptions)
    }

    private func filterByPerson(message: InboxMessageListItem) -> Bool {
        let selectedPeople = peopleSelectionViewModel.searchByPersonSelections
        let filter = filterSubject.value

        guard filter != .announcements else { return true }

        return messageMatchesPeopleFilter(
            participantName: message.participantName,
            selectedPeople: selectedPeople
        )
    }

    /// Handles when message filter gains focus - ensures people search loses focus
    private func handleFilterFocusChange() {
        guard isMessagesFilterFocused else { return }

        if peopleSelectionViewModel.isFocusedSubject.value {
            peopleSelectionViewModel.isFocusedSubject.accept(false)
        }
    }

    /// Handles filter option changes - updates scope and clears people search if needed
    private func handleFilterChange(_ filterOption: InboxFilterOption) {
        if let scope = filterOption.inboxMessageInteractorScope {
            _ = inboxMessageInteractor.setScope(scope)
        }

        if filterOption == .announcements {
            peopleSelectionViewModel.clearSearch()
        }
    }
}

private extension AnnouncementModel {
    var messageModel: InboxMessageModel {
        .init(
            announcement: self,
            entity: nil
        )
    }
}

private extension InboxMessageListItem {
    var messageModel: InboxMessageModel {
        .init(
            announcement: nil,
            entity: self
        )
    }
}
