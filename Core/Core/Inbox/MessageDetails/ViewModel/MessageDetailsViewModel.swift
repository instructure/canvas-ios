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

class MessageDetailsViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var messages: [MessageViewModel] = []
    @Published public private(set) var subject: String = ""
    public let title = NSLocalizedString("Message Details", comment: "")

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: MessageDetailsInteractor
    private let myID: String

    public init(router: Router, interactor: MessageDetailsInteractor, myID: String) {
        self.interactor = interactor
        self.myID = myID

        setupOutputBindings()
        // setupInputBindings(router: router)
    }

    private func setupOutputBindings() {
        interactor.state
                .assign(to: &$state)
        interactor.subject
            .assign(to: &$subject)
        interactor.messages
            .map { messages in
                messages.map {
                    MessageViewModel(item: $0, myID: self.myID, userMap: self.interactor.userMap)
                }
            }
            .assign(to: &$messages)
    }
}
