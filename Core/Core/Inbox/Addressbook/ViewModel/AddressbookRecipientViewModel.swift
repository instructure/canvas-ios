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

class AddressbookRecipientViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var recipients: [SearchRecipient]

    public let title = NSLocalizedString("Select Recipients", bundle: .core, comment: "")
    public let roleName: String

    // MARK: - Inputs
    public let recipientDidTap = PassthroughSubject<(recipient: [SearchRecipient], controller: WeakViewController), Never>()
    public let allRecipientDidTap = PassthroughSubject<(recipient: [SearchRecipient], controller: WeakViewController), Never>()

    // MARK: - Input / Output
    @Published public var searchText: String = ""

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private var router: Router

    public init(router: Router, roleName: String, recipients: [SearchRecipient], recipientDidSelect: CurrentValueRelay<[SearchRecipient]>) {
        self.recipients = recipients
        self.roleName = roleName
        self.router = router
        setupInputBindings(recipientDidSelect: recipientDidSelect)
    }

    public func filteredRecipients() -> [SearchRecipient] {
        guard !searchText.isEmpty else { return recipients }
        return recipients.filter { user in
            (user.displayName ?? user.fullName).lowercased().contains(searchText.lowercased())
        }
    }

    private func closeDialog(_ viewController: WeakViewController) {
        // Double dismiss is neccessary due to the searchable view
        router.dismiss(viewController)
        router.dismiss(viewController)
    }

    private func setupInputBindings(recipientDidSelect: CurrentValueRelay<[SearchRecipient]>) {
        recipientDidTap
            .sink { [weak self] (recipients, viewController) in
                recipientDidSelect.accept(recipients)
                self?.closeDialog(viewController)

            }
            .store(in: &subscriptions)

        allRecipientDidTap
            .sink { [weak self] (recipients, viewController) in
                recipientDidSelect.accept(recipients)
                self?.closeDialog(viewController)
            }
            .store(in: &subscriptions)
    }
}
