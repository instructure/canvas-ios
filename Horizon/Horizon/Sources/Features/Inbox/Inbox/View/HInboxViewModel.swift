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
import HorizonUI
import SwiftUI

@Observable
class HInboxViewModel {

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
            filterSubject.value.title
        }
        set {
            filterSubject.accept(FilterOption.allCases.first { $0.title == newValue } ?? .all)
        }
    }
    var isMessagesFilterFocused: Bool = false {
        didSet {
            onMessagesFilterFocused()
        }
    }
    var isSearchDisabled: Bool {
        filterSubject.value == .announcements
    }
    var messageListOpacity = 0.0
    var messageRows: [MessageRowViewModel] = []
    var peopleSelectionViewModel: PeopleSelectionViewModel!
    var screenState: InstUI.ScreenState = .data
    var spinnerOpacity = 1.0

    // MARK: - Private
    private var filterSubject: CurrentValueRelay<FilterOption> = CurrentValueRelay(FilterOption.all)
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
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
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

        _ = inboxMessageInteractor.setContext(.user(userID))

        weak var weakSelf = self
        Publishers.CombineLatest(
            inboxMessageInteractor.messages,
            announcementsInteractor.messages
        ).sink { _, _ in
            guard let self = weakSelf else { return }
            if inboxMessageInteractor.state.value != .data ||
                announcementsInteractor.state.value != .data {
                return
            }
            Publishers.CombineLatest(
                self.filterSubject,
                self.peopleSelectionViewModel.personFilterSubject
            )
            .sink { _ in weakSelf?.onInboxMessageListItems() }
            .store(in: &self.subscriptions)
        }
        .store(in: &subscriptions)

        filterSubject.sink { [weak self] filterOption in
            if let inboxMessageInteractorScope = filterOption.inboxMessageInteractorScope {
                _ = inboxMessageInteractor.setScope(inboxMessageInteractorScope)
            }
            if filterOption == .announcements {
                self?.peopleSelectionViewModel.clearSearch()
            }
        }
        .store(in: &subscriptions)
    }

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func goToComposeMessage(_ viewController: WeakViewController) {
        router.route(
            to: "/conversations/create",
            from: viewController
        )
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

    func refresh(endRefreshing: @escaping () -> Void) {
        inboxMessageInteractor
            .refresh()
            .sink { _ in
                endRefreshing()
            }
            .store(in: &subscriptions)
    }

    func viewMessage(
        announcement: Announcement?,
        inboxMessageListItem: InboxMessageListItem?,
        viewController: WeakViewController
    ) {
        if let inboxMessageListItem = inboxMessageListItem {
            router.route(
                to: "/conversations/\(inboxMessageListItem.id)",
                from: viewController
            )
        }
        if let announcement = announcement {
            router.route(
                to: "/announcements/\(announcement.id)",
                userInfo: ["announcement": announcement],
                from: viewController
            )
        }
    }

    // MARK: - Private Methods
    private func addAnnouncements(to messageRows: [MessageRowViewModel]) -> [MessageRowViewModel] {
        let isAnnouncementsShown = (
            filterSubject.value == .all ||
            filterSubject.value == .announcements
        ) && peopleSelectionViewModel.personFilterSubject.value.isEmpty

        let announcements: [MessageRowViewModel] = isAnnouncementsShown ? announcementsInteractor.messages.value.map { $0.viewModel } : []
        let isFinishedLoading = inboxMessageInteractor.hasNextPage.value == false
        // Combine the message rows and announcements, sorting them by date descending.
        let fullList = (messageRows + announcements).sorted { (lhs: MessageRowViewModel, rhs: MessageRowViewModel) in
            lhs.date ?? Date.distantPast > rhs.date ?? Date.distantPast
        }
        let indexOfLastNonAnnouncement = fullList.firstIndex { !$0.isAnnouncement } ?? 0

        // if we're finished loading the full list of announcements, show all the announcements + messages.
        // if we're not finished loading, only show the announcements that are before the last non-announcement.
        return fullList.enumerated().filter { (index, row) in
            return !row.isAnnouncement || isFinishedLoading || index < indexOfLastNonAnnouncement
        }.map { $0.element }
    }

    private func onInboxMessageListItems() {
        let messageRowsInterim = filterSubject.value.inboxMessageInteractorScope == nil ?
            [] :
            inboxMessageInteractor.messages.value
                .filter(filterByPerson)
                .map { $0.viewModel }

        messageRows = addAnnouncements(to: messageRowsInterim)
        messageListOpacity = messageRows.count > 0 ? 1.0 : 0.0
        spinnerOpacity = 0.0
    }

    private func filterByPerson(messageListItem: InboxMessageListItem) -> Bool {
        let personFilter = peopleSelectionViewModel.personFilterSubject.value
        if personFilter.isEmpty || filterSubject.value == .announcements {
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

    public struct MessageRowViewModel: Equatable, Hashable, Identifiable {
        let announcement: Announcement?
        var date: Date? {
            announcement?.date ?? inboxMessageListItem?.dateRaw
        }
        var dateString: String {
            date.map { $0.relativeDateTimeString } ?? ""
        }
        var title: String {
            if let announcement = announcement {
                if let courseName = announcement.courseName {
                    return String(
                        format: String(
                            localized: "Announcement in %@",
                            bundle: .horizon
                        ),
                        courseName
                    )
                }
                return String(localized: "Announcement", bundle: .horizon)
            }
            return inboxMessageListItem?.message ?? ""
        }
        var subtitle: String {
            if let announcement = announcement {
                return announcement.title
            }
            return inboxMessageListItem?.participantName ?? ""
        }
        var isAnnouncement: Bool {
            inboxMessageListItem == nil
        }
        var isAnnouncementIconVisible: Bool {
            isAnnouncement
        }
        var isNew: Bool {
            inboxMessageListItem?.isUnread == true
        }
        var id: String {
            if let announcement = announcement {
                return "announcement_\(announcement.id)"
            }
            return "message_\(inboxMessageListItem?.id ?? "")"
        }
        let inboxMessageListItem: InboxMessageListItem?
    }
}

extension Announcement {
    var viewModel: HInboxViewModel.MessageRowViewModel {
        .init(
            announcement: self,
            inboxMessageListItem: nil
        )
    }
}

extension InboxMessageListItem {
    var viewModel: HInboxViewModel.MessageRowViewModel {
        .init(
            announcement: nil,
            inboxMessageListItem: self
        )
    }
}
