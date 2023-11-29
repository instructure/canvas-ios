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

import Foundation
import Combine
import CombineExt

class AddressbookRoleViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var recipients: [SearchRecipient] = []
    @Published public private(set) var roles: [String] = []
    @Published public private(set) var roleRecipients: [String: [SearchRecipient]] = [:]

    public var isRolesViewVisible: Bool {
        searchText.value.isEmpty && !roles.isEmpty
    }
    public var isAllRecipientButtonVisible: Bool {
        searchText.value.isEmpty
    }

    public let title = NSLocalizedString("Select Recipients", bundle: .core, comment: "")
    public let recipientContext: RecipientContext

    // MARK: - Inputs
    public let roleDidTap = PassthroughSubject<(roleName: String, recipient: [SearchRecipient], controller: WeakViewController), Never>()
    public let recipientDidTap = PassthroughSubject<(recipient: [SearchRecipient], controller: WeakViewController), Never>()
    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()

    // MARK: - Input / Output
    @Published public var searchText = CurrentValueSubject<String, Never>("")

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: AddressbookInteractor
    private let router: Router

    public init(router: Router, recipientContext: RecipientContext, interactor: AddressbookInteractor, recipientDidSelect: CurrentValueRelay<[SearchRecipient]>) {
        self.interactor = interactor
        self.recipientContext = recipientContext
        self.router = router

        setupOutputBindings()
        setupInputBindings(recipientDidSelect: recipientDidSelect)
    }

    public func refresh() async {
        return await withCheckedContinuation { continuation in
            interactor.refresh().sink(
                receiveCompletion: {_ in
                    continuation.resume()
                }, receiveValue: { _ in }
            )
            .store(in: &subscriptions)
        }
    }

    private func setupOutputBindings() {
        interactor.state
            .assign(to: &$state)
        interactor.recipients
            .combineLatest(searchText)
            .map { (recipients, searchText) in
                recipients.filter { recipient in
                    if searchText.isEmpty {
                        true
                    } else {
                        recipient.name.lowercased().contains(searchText.lowercased())
                    }
                }
            }
            .assign(to: &$recipients)

        interactor.recipients
            .map { recipients in
                recipients.flatMap { recipient in
                    Array(recipient.commonCourses).map { commonCourse in
                        (recipient, commonCourse.role)
                    }
                }
            }
            .map { roleRecipients -> [String: [(SearchRecipient, String)]] in
                Dictionary(grouping: roleRecipients, by: { $0.1 })
            }
            .map { roleRecipients -> [String: [SearchRecipient]] in
                Dictionary(uniqueKeysWithValues: roleRecipients.map { [weak self] key, value in
                    (
                        self?.roleName(for: key) ?? "",
                        Array(Set(value.map { $0.0 }))
                    )
                })
            }
            .sink { [weak self] roleRecipients in
                self?.roles = Array(roleRecipients.keys).sorted()
                self?.roleRecipients = roleRecipients
            }
            .store(in: &subscriptions)
    }

    private func roleName(for roleType: String) -> String {
        switch roleType {
        case "TeacherEnrollment":
            return NSLocalizedString("Teachers", comment: "")
        case "StudentEnrollment":
            return NSLocalizedString("Students", comment: "")
        case "ObserverEnrollment":
            return NSLocalizedString("Observers", comment: "")
        case "TaEnrollment":
            return NSLocalizedString("Teaching assistants", comment: "")
        case "DesignerEnrollment":
            return NSLocalizedString("Course designers", comment: "")
        default:
            return NSLocalizedString("Others", comment: "")
        }
    }

    private func closeDialog(_ viewController: WeakViewController) {
        // Double dismiss is neccessary due to the searchable view
        router.dismiss(viewController)
        router.dismiss(viewController)
    }

    private func setupInputBindings(recipientDidSelect: CurrentValueRelay<[SearchRecipient]>) {
        cancelButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        roleDidTap
            .sink { [weak self] (roleName, recipients, viewController) in
                if let self {
                    self.router.show(
                        AddressBookAssembly.makeAddressbookRecipientViewController(
                            recipientContext: self.recipientContext,
                            roleName: roleName,
                            recipients: recipients,
                            recipientDidSelect: recipientDidSelect
                        ),
                        from: viewController
                    )
                }
            }
            .store(in: &subscriptions)

        recipientDidTap
            .sink { [weak self] (recipient, viewController) in
                recipientDidSelect.accept(recipient)
                self?.closeDialog(viewController)
            }
            .store(in: &subscriptions)
    }
}
