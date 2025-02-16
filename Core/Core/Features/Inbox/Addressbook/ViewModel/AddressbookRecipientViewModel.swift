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
    @Published public private(set) var recipients: [Recipient]
    @Published public private(set) var selectedRecipients: [Recipient] = []
    public var allRecipient: Recipient {
        Recipient(ids: recipients.flatMap { $0.ids }, name: "All in \(roleName)", avatarURL: nil)
    }

    public var isAllRecipientButtonVisible: Bool {
        searchText.value.isEmpty && canSelectAllRecipient
    }

    public let title = String(localized: "Select Recipients", bundle: .core)
    public let roleName: String

    // MARK: - Inputs
    public let recipientDidTap = PassthroughSubject<Recipient, Never>()
    public let doneButtonDidTap = PassthroughRelay<WeakViewController>()

    // MARK: - Input / Output
    @Published public var searchText = CurrentValueSubject<String, Never>("")

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router
    private let canSelectAllRecipient: Bool

    public init(
        router: Router,
        roleName: String,
        recipients: [Recipient],
        canSelectAllRecipient: Bool,
        recipientDidSelect: PassthroughRelay<Recipient>,
        selectedRecipients: CurrentValueSubject<[Recipient], Never>
    ) {
        self.recipients = recipients
        self.roleName = roleName
        self.router = router
        self.canSelectAllRecipient = canSelectAllRecipient

        setupInputBindings(recipientDidSelect: recipientDidSelect)
        setupOutputBindings(allRecipient: recipients, selectedRecipients: selectedRecipients)
    }

    private func setupOutputBindings(allRecipient: [Recipient], selectedRecipients: CurrentValueSubject<[Recipient], Never>) {
        Just(allRecipient)
            .combineLatest(searchText)
            .map { (recipients, searchText) in

                let foundResults = recipients.filter { recipient in
                    if searchText.isEmpty {
                        true
                    } else {
                        recipient.displayName.lowercased().contains(searchText.lowercased())
                    }
                }

                if searchText.isNotEmpty {
                    let format = String(localized: "d_results_found", bundle: .core)
                    let message = String.localizedStringWithFormat(format, foundResults.count)
                    UIAccessibility.announce(message)
                }

                return foundResults
            }
            .assign(to: &$recipients)

        selectedRecipients
            .assign(to: &$selectedRecipients)
    }

    private func setupInputBindings(recipientDidSelect: PassthroughRelay<Recipient>) {
        recipientDidTap
            .sink { recipient in
                recipientDidSelect.accept(recipient)
            }
            .store(in: &subscriptions)

        doneButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }
}
