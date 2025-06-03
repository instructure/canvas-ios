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
    var personOptions: [String] = []
    var searchByPersonSelections: [String] {
        get {
            personFilterSubject.value
        }
        set {
            personFilterSubject.send(newValue)
        }
    }
    var searchString: String = "" {
        didSet {
            onSearchStringSet()
        }
    }
    var searchLoading: Bool = false
    var isSearchDisabled: Bool {
        filter == .announcements
    }
    var isSearchFocused: Bool = false {
        didSet {
            onSearchFocused()
        }
    }

    // MARK: - Private

    private let personFilterSubject = CurrentValueSubject<[String], Never>([])
    // don't do animations until the user updates the filter or search
    private var searchAPITask: APITask?
    private var searchDebounceTask: Task<Void, Never>?
    private var subscriptions = Set<AnyCancellable>()
    private var filter: FilterOption = FilterOption.all {
        didSet {
            didSetFilter()
        }
    }

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

        _ = inboxMessageInteractor.setContext(.user(AppEnvironment.shared.currentSession?.userID ?? ""))

        Publishers.CombineLatest(
            inboxMessageInteractor.messages,
            personFilterSubject
        )
        .sink(receiveValue: onInboxMessageListItems)
        .store(in: &subscriptions)

        inboxMessageInteractor
            .hasNextPage
            .sink(receiveValue: onHasNextPage)
            .store(in: &subscriptions)
    }

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    // MARK: - Private Methods

    private func onHasNextPage(_ hasNextPage: Bool) {
    }

    private func onInboxMessageListItems(tuple: ([InboxMessageListItem], [String])) {
        let inboxMessageListItems = tuple.0
        let personFilter = tuple.1
        messageRows = inboxMessageListItems
            .filter { messageListItem in
                // technically, this should probably be in the interactor...
                if personFilter.isEmpty || filter == .announcements {
                    return true
                }
                return personFilter.contains { current in
                    messageListItem.participantName.lowercased().contains(current.lowercased())
                }
            }
            .map { messageListItem in
                MessageRowViewModel(
                    date: messageListItem.date,
                    title: messageListItem.title,
                    subtitle: messageListItem.participantName,
                    isNew: messageListItem.isUnread
                )
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

    private func onSearchStringSet() {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled {
                return
            }
            self?.makeRequest()
        }
    }

    private func onSearchFocused() {
        if isSearchFocused {
            makeRequest()
        }
    }

    private func makeRequest() {
        searchLoading = true
        searchAPITask?.cancel()
        searchAPITask = api.makeRequest(
            GetSearchRecipientsRequest(
                context: .user(AppEnvironment.shared.currentSession?.userID ?? ""),
                search: searchString,
                perPage: 10
            )
        ) { [weak self] apiSearchRecipients, _, _ in
            guard let apiSearchRecipients = apiSearchRecipients else {
                return
            }
            self?.personOptions = apiSearchRecipients.map { $0.name }
            self?.searchLoading = false
        }
    }

    struct MessageRowViewModel: Hashable, Identifiable {
        let date: String
        let title: String
        let subtitle: String
        let isNew: Bool
        var id: String {
            "\(date)-\(title)-\(subtitle)-\(isNew)"
        }
    }
}

extension Announcement {
    var viewModel: HorizonInboxViewModel.MessageRowViewModel {
        .init(
            date: date.map { $0.relativeDateOnlyString } ?? "",
            title: viewModelTitle,
            subtitle: title,
            isNew: false
        )
    }

    private var viewModelTitle: String {
        courseName != nil ? "Announcement for \(courseName ?? "")" : "Announcement"
    }
}
