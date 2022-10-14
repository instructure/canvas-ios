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

#if DEBUG

import Combine
import SwiftUI

public class InboxViewModelPreview: InboxViewModel {
    @Published public var state: InboxViewModelState = .data
    public var topBarMenuViewModel = TopBarViewModel(items: InboxMessageScope.allCases.map {
        TopBarItemViewModel(id: $0.rawValue, icon: nil, label: Text($0.localizedName))
    })
    @Published public private(set) var messages: [InboxMessageModel]

    private var scope = InboxMessageScope.all
    private var subscriptions = Set<AnyCancellable>()

    public init(messages: [InboxMessageModel]) {
        self.messages = messages
        topBarMenuViewModel.$selectedItemIndex
            .map { InboxMessageScope.allCases[$0] }
            .sink { [weak self] scope in
                self?.scopeDidChange(to: scope)
            }
            .store(in: &subscriptions)
    }

    public func refresh(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
    }

    public func scopeDidChange(to scope: InboxMessageScope) {
        self.scope = scope
        state = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            switch scope {
            case .all, .sent, .archived:
                state = .data
            case .unread:
                state = .empty
            case .starred:
                state = .error
            }
        }
    }
}

#endif
