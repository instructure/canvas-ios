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
import CombineExt

class AddressbookViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var recipients: [Recipient] = []

    public let title = NSLocalizedString("Select Recipients", bundle: .core, comment: "")

    // MARK: - Inputs
    public let recipientDidTap = PassthroughSubject<(recipient: Recipient, controller: WeakViewController), Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: AddressbookInteractor

    public init(router: Router, interactor: AddressbookInteractor, recipientDidSelect: CurrentValueRelay<Recipient?>) {
        self.interactor = interactor

        setupOutputBindings()
        setupInputBindings(router: router, recipientDidSelect: recipientDidSelect)
    }

    private func setupOutputBindings() {
        interactor.state
                .assign(to: &$state)
        interactor.recipients
            .map {
                $0.map { recipient in
                    Recipient(searchRecipient: recipient)
                }
            }
            .assign(to: &$recipients)
    }

    private func setupInputBindings(router: Router, recipientDidSelect: CurrentValueRelay<Recipient?>) {
        recipientDidTap
            .sink { [router] (recipient, viewController) in
                recipientDidSelect.accept(recipient)
                router.pop(from: viewController)
            }
            .store(in: &subscriptions)
    }
}
