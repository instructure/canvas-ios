//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class AddressbookInteractorLive: AddressbookInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)

    public var recipients = CurrentValueSubject<[SearchRecipient], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let recipientStore: Store<GetSearchRecipients>

    public init(env: AppEnvironment, recipientContext: RecipientContext) {
        self.recipientStore = env.subscribe(GetSearchRecipients(context: recipientContext.context))

        recipientStore
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        recipientStore
            .allObjects
            .subscribe(recipients)
            .store(in: &subscriptions)
        recipientStore.exhaust()
    }

    public func refresh() -> Future<Void, Never> {
        recipientStore.refreshWithFuture(force: true)
    }
}
