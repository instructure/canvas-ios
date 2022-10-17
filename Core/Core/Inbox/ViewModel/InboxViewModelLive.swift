//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import SwiftUI

public class InboxViewModelLive: InboxViewModel {
    // MARK: - Outputs
    @Published public private(set) var state: InboxViewModelState = .loading
    @Published public private(set) var messages: [InboxMessageModel]
    @Published public var topBarMenuViewModel: TopBarViewModel

    // MARK: - Inputs
    public private(set) var refresh = PassthroughSubject<() -> Void, Never>()
    public private(set) var menuTapped = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private State
    private let env: AppEnvironment
    private var messagesStore: Store<GetConversations>?
    private var subscriptions = Set<AnyCancellable>()

    public init(env: AppEnvironment) {
        self.env = env
        self.messages = []
        self.topBarMenuViewModel = TopBarViewModel(items: InboxMessageScope.allCases.map {
            TopBarItemViewModel(id: $0.rawValue, icon: nil, label: Text($0.localizedName))
        })
        subscribeToTopMenuChanges()
        subscribeToRefreshEvents()
        subscribeToMenuTapEvents()
    }

    private func subscribeToMenuTapEvents() {
        menuTapped
            .sink { [weak router=env.router] source in
                router?.route(to: "/profile", from: source, options: .modal())
            }
            .store(in: &subscriptions)
    }

    private func subscribeToTopMenuChanges() {
        topBarMenuViewModel.selectedItemIndexPublisher
            .removeDuplicates()
            .map { InboxMessageScope.allCases[$0] }
            .sink { [weak self] scope in
                self?.scopeDidChange(to: scope)
            }
            .store(in: &subscriptions)
    }

    private func subscribeToRefreshEvents() {
        refresh
            .sink { [weak self] completion in
                self?.messagesStore?.refresh(force: true) { _ in
                    completion()
                }
            }
            .store(in: &subscriptions)
    }

    private func scopeDidChange(to scope: InboxMessageScope) {
        state = .loading
        messages = []
        messagesStore = env.subscribe(GetConversations(scope: scope.apiScope, filter: nil)) { [weak self] in
            self?.messagesStoreUpdated()
        }
        messagesStore?.refresh(force: true)
    }

    private func messagesStoreUpdated() {
        guard let messagesStore = messagesStore,
              messagesStore.state != .loading
        else {
            return
        }

        switch messagesStore.state {
        case .empty:
            state = .empty
        case .data:
            messages = messagesStore.all.map { InboxMessageModel(conversation: $0) }
            state = .data
        case .error, .loading:
            state = .error
        }
    }
}
