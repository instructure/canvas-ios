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
import HorizonUI
import SwiftUI

@Observable
class HorizonInboxViewModel {

    enum FilterOption: CaseIterable {
        // caution: ordering here matters, it is used in the UI
        case all
        case announcements
        case unread
        case sent

        var title: String {
            switch self {
            case .all:
                return String(localized: "All Messages", bundle: .horizon)
            case .announcements:
                return String(localized: "Announcements", bundle: .horizon)
            case .unread:
                return String(localized: "Unread", bundle: .horizon)
            case .sent:
                return String(localized: "Sent", bundle: .horizon)
            }
        }

        var inboxMessageInteractorScope: InboxMessageScope? {
            let map = [
                FilterOption.all: InboxMessageScope.inbox,
                FilterOption.unread: InboxMessageScope.unread,
                FilterOption.sent: InboxMessageScope.sent
            ]
            return map[self]
        }
    }

    // MARK: - Outputs
    var filterTitle: String {
        get {
            filter.title
        }
        set {
            filter = FilterOption.allCases.first { $0.title == newValue } ?? .all
        }
    }
    var messageRows: [MessageRowViewModel] = []
    var isMessagesFilterFocused: Bool = false {
        didSet {
            onMessagesFilterFocused()
        }
    }
    var isSearchDisabled: Bool {
        filter == .announcements
    }
    var peopleSelectionViewModel: PeopleSelectionViewModel!

    // MARK: - Private
    private var filter: FilterOption = FilterOption.all {
        didSet {
            didSetFilter()
        }
    }
    private var hasNextPage: Bool = false
    // don't do animations until the user updates the filter or search
    private var isSearchFocused: Bool = false {
        didSet {
            onSearchFocused()
        }
    }
    private var searchAPITask: APITask?
    private var searchDebounceTask: Task<Void, Never>?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let announcementsInteractor: AnnouncementsInteractor
    private let api: API
    private let inboxMessageInteractor: InboxMessageInteractor
    private let router: Router

    init(
        api: API = AppEnvironment.shared.api,
        router: Router = AppEnvironment.shared.router,
        inboxMessageInteractor: InboxMessageInteractor = InboxMessageInteractorLive(
            env: AppEnvironment.shared,
            tabBarCountUpdater: .init(),
            messageListStateUpdater: .init()
        ),
        announcementsInteractor: AnnouncementsInteractor = AnnouncementsInteractorLive()
    ) {
        self.api = api
        self.router = router
        self.inboxMessageInteractor = inboxMessageInteractor
        self.announcementsInteractor = announcementsInteractor
        self.peopleSelectionViewModel = .init()

        _ = inboxMessageInteractor.setContext(.user(AppEnvironment.shared.currentSession?.userID ?? ""))

        Publishers.CombineLatest(
            inboxMessageInteractor.messages,
            peopleSelectionViewModel.personFilterSubject
        )
        .sink(receiveValue: onInboxMessageListItems)
        .store(in: &subscriptions)
    }

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func goToComposeMessage(_ viewController: WeakViewController) {
        router.route(to: "/conversations/create", from: viewController)
    }

    func loadMoreIfScrolledEnough(
        scrollViewProxy: GeometryProxy,
        contentProxy: GeometryProxy,
        coordinateSpaceName: String = "scroll"
    ) {
        let isLoadingMore = inboxMessageInteractor.state.value == .loading
        let hasNextPage = inboxMessageInteractor.hasNextPage.value
        if(!hasNextPage && !isLoadingMore) {
            return
        }
        let contentHeight = contentProxy.size.height
        let visibleHeight = scrollViewProxy.size.height
        let offset = -contentProxy.frame(in: .named(coordinateSpaceName)).minY
        let maxOffset = max(contentHeight - visibleHeight, 1)
        let threshold = 150.0
        let shouldLoadMore = offset > maxOffset - threshold
        if !shouldLoadMore {
            return
        }
        _ = inboxMessageInteractor.loadNextPage()
    }

    // MARK: - Private Methods
    private func addAnnouncements(to messageRows: [MessageRowViewModel]) -> [MessageRowViewModel] {
        if filter != .all || peopleSelectionViewModel.personFilterSubject.value.isNotEmpty {
            return messageRows
        }
        let announcements: [MessageRowViewModel] = announcementsInteractor.messages.value.map { $0.viewModel }
        let isFinishedLoading = inboxMessageInteractor.hasNextPage.value == false
        let fullList = (messageRows + announcements).sorted { (lhs: MessageRowViewModel, rhs: MessageRowViewModel) in
            lhs.date ?? Date.distantPast > rhs.date ?? Date.distantPast
        }
        let indexOfLastNonAnnouncement = fullList.firstIndex { !$0.isAnnouncement } ?? 0
        return fullList.enumerated().filter { (index, row) in
            // if we're finished loading, show all the announcements and messages.
            // if we're not finished loading, only show the announcements that are before the last non-announcement.
            return !row.isAnnouncement || isFinishedLoading || index < indexOfLastNonAnnouncement
        }.map { $0.element }
    }

    private func onInboxMessageListItems(tuple: ([InboxMessageListItem], [HorizonUI.MultiSelect.Option])) {
        let inboxMessageListItems = tuple.0
        let messageRowsInterim = inboxMessageListItems
            .filter(filterByPerson)
            .map { $0.viewModel }
        messageRows = addAnnouncements(to: messageRowsInterim)
        messageRows.forEach {
            print($0.id)
        }
    }

    private func didSetFilter() {
        guard let filterOption = FilterOption.allCases.first(where: { $0 == self.filter }) else {
            return
        }
        messageRows = []
        if let inboxMessageInteractorScope = filterOption.inboxMessageInteractorScope {
            _ = inboxMessageInteractor.setScope(inboxMessageInteractorScope)
        } else {
            announcementsInteractor
                .messages
                .sink { [weak self] announcements in
                    self?.messageRows = announcements.map { $0.viewModel }
                }
                .store(in: &subscriptions)
        }
    }

    private func filterByPerson(messageListItem: InboxMessageListItem) -> Bool {
        let personFilter = peopleSelectionViewModel.personFilterSubject.value
        if personFilter.isEmpty || filter == .announcements {
            return true
        }
        return personFilter.contains { current in
            messageListItem.participantName.lowercased().contains(current.label.lowercased())
        }
    }

    private func onMessagesFilterFocused() {
        if isMessagesFilterFocused {
            isSearchFocused = false
        }
    }

    private func onSearchFocused() {
        if isSearchFocused {
            isMessagesFilterFocused = false
        }
    }

    struct MessageRowViewModel: Hashable, Identifiable {
        let date: Date?
        var dateString: String {
            date.map { $0.relativeDateOnlyString } ?? ""
        }
        let title: String
        let subtitle: String
        let isAnnouncement: Bool
        let isNew: Bool
        var id: String {
            "\(date?.timeIntervalSince1970 ?? 0)-\(title)-\(subtitle)-\(isNew)-\(isAnnouncement)"
        }
    }
}

extension Announcement {
    var viewModel: HorizonInboxViewModel.MessageRowViewModel {
        .init(
            date: date,
            title: viewModelTitle,
            subtitle: title,
            isAnnouncement: true,
            isNew: false
        )
    }

    private var viewModelTitle: String {
        courseName != nil ? "Announcement for \(courseName ?? "")" : "Announcement"
    }
}

extension InboxMessageListItem {
    var viewModel: HorizonInboxViewModel.MessageRowViewModel {
        .init(
            date: dateRaw,
            title: title,
            subtitle: participantName,
            isAnnouncement: false,
            isNew: isUnread
        )
    }
}
