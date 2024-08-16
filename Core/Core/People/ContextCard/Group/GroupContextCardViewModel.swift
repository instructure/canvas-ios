//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class GroupContextCardViewModel: ObservableObject {
    @Published public var pending = true
    // There's no good API to fetch a user's profile in a group, so we re-use what is fetched on the People List
    public lazy var user: Store<LocalUseCase<User>> = env.subscribe(scope: .where(#keyPath(User.id), equals: userID)) { [weak self] in self?.updateLoadingState() }
    public lazy var group = env.subscribe(GetGroup(groupID: groupID)) { [weak self] in self?.updateLoadingState() }
    public lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in self?.updateLoadingState() }
    public lazy var permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .sendMessages ])) { [weak self] in self?.updateLoadingState() }
    public var shouldShowMessageButton: Bool { isViewingAnotherUser && permissions.first?.sendMessages == true }
    public let context: Context

    private let env = AppEnvironment.shared
    private let isViewingAnotherUser: Bool
    private var isFirstAppear = true
    private let groupID: String
    private let userID: String

    public init(groupID: String, userID: String, currentUserID: String) {
        self.groupID = groupID
        self.userID = userID
        self.context = Context.group(groupID)
        self.isViewingAnotherUser = (userID != currentUserID)
    }

    public func viewAppeared() {
        guard isFirstAppear else { return }
        isFirstAppear = false
        colors.refresh()
        group.refresh()
        permissions.refresh()
        user.refresh()
    }

    public func openNewMessageComposer(controller: UIViewController) {
        guard shouldShowMessageButton, let group = group.first, let user = user.first else { return }

        let composeMessageOptions = ComposeMessageOptions(
            disabledFields: .init(contextDisabled: true, recipientsDisabled: true),
            fieldsContents: .init(
                selectedContext: .init(name: group.name, context: context),
                selectedRecipients: [Recipient(id: user.id, name: user.name, avatarURL: user.avatarURL?.absoluteURL)])
        )

        env.router.route(
            to: URLComponents.parse("/conversations/compose", queryItems: composeMessageOptions.queryItems),
            from: controller,
            options: .modal(embedInNav: true)
        )
    }

    private func updateLoadingState() {
        let newPending = user.pending || group.pending || colors.pending || permissions.pending
        if newPending == true { return }
        pending = newPending
    }
}
