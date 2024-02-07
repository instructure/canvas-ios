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
    @Published public private(set) var recipients: [Recipient] = []
    @Published public private(set) var selectedRecipients: [Recipient] = []
    @Published public private(set) var roles: [String] = []
    @Published public private(set) var roleRecipients: [String: [Recipient]] = [:]

    public var isRolesViewVisible: Bool {
        searchText.value.isEmpty && !roles.isEmpty
    }

    public var isAllRecipientButtonVisible: Bool {
        searchText.value.isEmpty && canSelectAllRecipient
    }

    public var allRecipient: Recipient {
        Recipient(ids: recipients.flatMap { $0.ids }, name: "All in \(recipientContext.name)", avatarURL: nil)
    }

    public let title = NSLocalizedString("Select Recipients", bundle: .core, comment: "")
    public let recipientContext: RecipientContext

    // MARK: - Inputs
    public let roleDidTap = PassthroughSubject<(roleName: String, recipients: [Recipient], controller: WeakViewController), Never>()
    public let recipientDidTap = PassthroughSubject<Recipient, Never>()
    public let doneButtonDidTap = PassthroughRelay<WeakViewController>()

    // MARK: - Input / Output
    @Published public var searchText = CurrentValueSubject<String, Never>("")

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: AddressbookInteractor
    private let router: Router
    private var env: AppEnvironment
    private var canSelectAllRecipient: Bool {
        var isNotStudent = false
        if let userId = env.currentSession?.userID {
            roleRecipients.forEach { (roleName, recipients) in
                if roleName != NSLocalizedString("Students", comment: "") && recipients.flatMap({ $0.ids }).contains(userId) {
                    isNotStudent = true
                    return
                }
            }
        }
        return isNotStudent
    }

    public init(
        env: AppEnvironment,
        router: Router,
        recipientContext: RecipientContext,
        interactor: AddressbookInteractor,
        recipientDidSelect: PassthroughRelay<Recipient>,
        selectedRecipients: CurrentValueSubject<[Recipient], Never>
    ) {
        self.interactor = interactor
        self.recipientContext = recipientContext
        self.router = router
        self.env = env

        setupOutputBindings(selectedRecipients: selectedRecipients)
        setupInputBindings(recipientDidSelect: recipientDidSelect, selectedRecipients: selectedRecipients)
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

    private func setupOutputBindings(selectedRecipients: CurrentValueSubject<[Recipient], Never>) {
        interactor.state
            .assign(to: &$state)
        interactor.recipients
            .map { searchRecipients in
                searchRecipients.map { Recipient(searchRecipient: $0) }
            }
            .combineLatest(searchText)
            .map { (recipients, searchText) in
                recipients.filter { recipient in
                    if searchText.isEmpty {
                        true
                    } else {
                        recipient.displayName.lowercased().contains(searchText.lowercased())
                    }
                }
            }
            .assign(to: &$recipients)

        interactor.recipients
            .map { recipients -> [String: [Recipient]] in
                var recipientsByRole: [String: [Recipient]] = [:]

                for recipient in recipients {
                    for role in recipient.roleNames {
                        var recipientsForRole = recipientsByRole[role] ?? []
                        recipientsForRole.append(Recipient(searchRecipient: recipient))
                        recipientsByRole[role] = recipientsForRole
                    }
                }

                return recipientsByRole
            }
            .sink { [weak self] recipientsByRoles in
                self?.roles = Array(recipientsByRoles.keys).sorted()
                self?.roleRecipients = recipientsByRoles
            }
            .store(in: &subscriptions)

        selectedRecipients
            .assign(to: &$selectedRecipients)
    }

    private func setupInputBindings(recipientDidSelect: PassthroughRelay<Recipient>, selectedRecipients: CurrentValueSubject<[Recipient], Never>) {
        doneButtonDidTap
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
                            canSelectAllRecipient: self.canSelectAllRecipient,
                            recipientDidSelect: recipientDidSelect,
                            selectedRecipients: selectedRecipients
                        ),
                        from: viewController
                    )
                }
            }
            .store(in: &subscriptions)

        recipientDidTap
            .sink { recipient in
                recipientDidSelect.accept(recipient)
            }
            .store(in: &subscriptions)
    }
}

private extension SearchRecipient {

    var roleNames: Set<String> {
        Set(commonCourses.map { Self.roleName(from: $0.role) })
    }

    static func roleName(from enrollmentName: String) -> String {
        switch enrollmentName {
        case "TeacherEnrollment":
            return NSLocalizedString("Teachers", comment: "")
        case "StudentEnrollment":
            return NSLocalizedString("Students", comment: "")
        case "ObserverEnrollment":
            return NSLocalizedString("Observers", comment: "")
        case "TaEnrollment":
            return NSLocalizedString("Teaching Assistants", comment: "")
        case "DesignerEnrollment":
            return NSLocalizedString("Course Designers", comment: "")
        default:
            return NSLocalizedString("Others", comment: "")
        }
    }
}
