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

import SwiftUI

public class InboxViewModelLive: InboxViewModel {
    @Published public private(set) var state: InboxViewModelState = .loading
    public var topBarMenuViewModel = TopBarViewModel(items: InboxMessageScope.allCases.map {
        TopBarItemViewModel(id: $0.rawValue, icon: nil, label: Text($0.localizedName))
    })
    @Published public private(set) var messages: [InboxMessageModel]

    private let env: AppEnvironment
    private var messagesStore: Store<GetConversations>

    public init(env: AppEnvironment) {
        self.env = env
        self.messages = []
        self.messagesStore = Self.messagesStore(env: env, scope: .all)
        messagesStore.eventHandler = { [weak self] in
            self?.messagesStoreUpdated()
        }
    }

    public func refresh(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
    }

    public func scopeDidChange(to scope: InboxMessageScope) {
//        @Published public var scope: InboxMessageScope = .all {
//            didSet {
//                messagesStore = Self.messagesStore(env: env, scope: .all)
//                messagesStore.eventHandler = { [weak self] in
//                    self?.messagesStoreUpdated()
//                }
//            }
//        }
    }

    private func messagesStoreUpdated() {
        messages = messagesStore.all.map { InboxMessageModel(conversation: $0) }
    }

    private static func messagesStore(env: AppEnvironment, scope: InboxMessageScope) -> Store<GetConversations> {
        env.subscribe(GetConversations(scope: scope.apiScope, filter: nil)).refresh()
    }
}
