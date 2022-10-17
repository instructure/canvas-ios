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

public protocol InboxViewModel: ObservableObject {
    // MARK: - Outputs
    var state: InboxViewModelState { get }
    var topBarMenuViewModel: TopBarViewModel { get }
    var messages: [InboxMessageModel] { get }
    var emptyState: (scene: PandaScene, title: String, text: String) { get }
    var errorState: (title: String, text: String) { get }

    // MARK: - Inputs
    var refresh: PassthroughSubject<() -> Void, Never> { get }
    var menuTapped: PassthroughSubject<WeakViewController, Never> { get }
}

public extension InboxViewModel {
    var emptyState: (scene: PandaScene, title: String, text: String) {
        (scene: SpacePanda() as PandaScene,
         title: NSLocalizedString("No Messages", comment: ""),
         text: NSLocalizedString("Tap the \"+\" to create a new conversation", comment: ""))
    }
    var errorState: (title: String, text: String) {
        (title: NSLocalizedString("Something Went Wrong", comment: ""),
         text: NSLocalizedString("Pull to refresh to try again", comment: ""))
    }
}

public enum InboxViewModelState {
    case loading
    case empty
    case data
    case error
}
