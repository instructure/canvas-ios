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

@Observable
final class HInboxViewModel {
    // MARK: - Outputs

    var filterTitle: String {
        get { filterSubject.value.title }
        set {
            filterSubject.accept(InboxFilterOption.allCases.first { $0.title == newValue } ?? .all)
            _ = inboxMessageInteractor.refresh()
        }
    }

    var isMessagesFilterFocused: Bool = false {
        didSet {
            onMessagesFilterFocused()
        }
    }
    var isSearchDisabled: Bool { filterSubject.value == .announcements }
    private(set) var messageRows: [InboxMessageModel] = []
    private(set) var peopleSelectionViewModel: RecipientSelectionViewModel
    private(set) var screenState: InstUI.ScreenState = .loading

    // MARK: - Private

    private var filterSubject: CurrentValueRelay<InboxFilterOption> = CurrentValueRelay(InboxFilterOption.all)
    private var subscriptions = Set<AnyCancellable>()

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
        filterSubject.sink { [weak self] filterOption in
            if let inboxMessageInteractorScope = filterOption.inboxMessageInteractorScope {
                _ = inboxMessageInteractor.setScope(inboxMessageInteractorScope)
            }
            if filterOption == .announcements {
                self?.peopleSelectionViewModel.clearSearch()
            }
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
            .zip(fetchAnnouncements(ignoreCache: true))
            .sink { _, _ in endRefreshing() }
            .store(in: &subscriptions)
    }

    func viewMessage(
        announcement: AnnouncementModel?,
        inboxMessageListItem: InboxMessageListItem?,
        viewController: WeakViewController
    ) {
        if let inboxMessageListItem = inboxMessageListItem {
            router.route(
                to: "/conversations/\(inboxMessageListItem.id)",
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

    // MARK: - Private Functions

    private func addAnnouncements(to messageRows: [InboxMessageModel], announcements: [AnnouncementModel]) -> [InboxMessageModel] {
        let filter = filterSubject.value
        let isPeopleFilterEmpty = peopleSelectionViewModel.searchByPersonSelections.isEmpty

        let shouldShowAnnouncements =
        (filter == .all || filter == .announcements) &&
        isPeopleFilterEmpty

        let announcementRows: [InboxMessageModel] = {
            guard shouldShowAnnouncements else {
                return filter == .unread
                ? announcements.filter { !$0.isRead }.map(\.messageModel)
                : []
            }
            return announcements.map(\.messageModel)
        }()

        return (messageRows + announcementRows)
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    private func fetchAnnouncements(ignoreCache: Bool = false) -> AnyPublisher<[AnnouncementModel], Never> {
        announcementInteractor
            .getAllAnnouncements(ignoreCache: ignoreCache)
            .eraseToAnyPublisher()
    }

    private func listenForMessagesAndAnnouncements() {
        Publishers.CombineLatest4(
            inboxMessageInteractor.messages,
            fetchAnnouncements(),
            filterSubject,
            peopleSelectionViewModel.personSelectionPublisher
        )
        .map { [weak self] _, announcements, filter, _ -> ([InboxMessageModel], [AnnouncementModel])in
            guard let self, filter.inboxMessageInteractorScope != nil else { return ([], announcements) }
            let messages = self.inboxMessageInteractor.messages.value
                       .filter(self.filterByPerson)
                       .map(\.messageModel)
            return (messages, announcements)
        }
        .sink { [weak self] messages, announcements in
            guard let self else { return }
            messageRows = addAnnouncements(to: messages, announcements: announcements)
            screenState = .data
        }
        .store(in: &subscriptions)
    }

    private func filterByPerson(message: InboxMessageListItem) -> Bool {
        let selectedPeople = peopleSelectionViewModel.searchByPersonSelections
        let filter = filterSubject.value
        guard !selectedPeople.isEmpty, filter != .announcements else { return true }
        let messageName = message.participantName.lowercased()
        return selectedPeople.contains {
            messageName.contains($0.label.lowercased())
        }
    }

    private func onMessagesFilterFocused() {
        guard isMessagesFilterFocused, peopleSelectionViewModel.isFocusedSubject.value else { return }
        peopleSelectionViewModel.isFocusedSubject.accept(false)
    }
}

private extension AnnouncementModel {
    var messageModel: InboxMessageModel {
        .init(
            announcement: self,
            inboxMessageListItem: nil
        )
    }
}

private extension InboxMessageListItem {
    var messageModel: InboxMessageModel {
        .init(
            announcement: nil,
            inboxMessageListItem: self
        )
    }
}
