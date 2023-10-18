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

class ComposeMessageViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var courses: [InboxCourse] = []
    @Published public private(set) var recipients: [SearchRecipient] = []

    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""
    @Published public var selectedCourse: InboxCourse?

    public let title = NSLocalizedString("New Message", bundle: .core, comment: "")
    public var sendButtonActive: Bool {
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !recipients.isEmpty
        //&& (attachments.isEmpty || attachments.allSatisfy({ $0.isUploaded }))

    }

    // MARK: - Inputs
    public let sendButtonDidTap = PassthroughRelay<WeakViewController>()
    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let addRecipientButtonDidTap = PassthroughRelay<WeakViewController>()
    public let selectedRecipient = CurrentValueRelay<SearchRecipient?>(nil)

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let router: Router

    public init(router: Router, interactor: ComposeMessageInteractor) {
        self.interactor = interactor
        self.router = router

        setupOutputBindings()
        setupInputBindings(router: router)
    }

    public func courseSelectButtonDidTap(viewController: WeakViewController) {
        let options = courses
        var selected: IndexPath?
        if let selectedCourse = selectedCourse {
            selected = options.firstIndex(of: selectedCourse).flatMap {
                IndexPath(row: $0, section: 0)
            }
        }
        let sections = [ ItemPickerSection(items: options.map {
            ItemPickerItem(title: $0.name)
        }), ]

        router.show(ItemPickerViewController.create(
            title: NSLocalizedString("Select Course", comment: ""),
            sections: sections,
            selected: selected,
            didSelect: {
                self.selectedCourse = options[$0.row]
                self.recipients.removeAll()
            }
        ), from: viewController)
    }

    public func addRecipientButtonDidTap(viewController: WeakViewController) {
        guard let courseID = selectedCourse?.courseId else { return }
        let addressbook = AddressBookAssembly.makeAddressbookViewController(courseID: courseID, recipientDidSelect: selectedRecipient)
        router.show(addressbook, from: viewController)
    }
    
    public func attachmentbuttonDidTap(viewController: WeakViewController) {
        
    }

    public func removeRecipientButtonDidTap(recipient: SearchRecipient) {
        recipients.removeAll { $0 == recipient}
    }

    private func setupOutputBindings() {
        interactor.state
                .assign(to: &$state)
        interactor.courses
            .assign(to: &$courses)
        selectedRecipient
            .compactMap { $0 }
            .sink { [weak self] in
                print(self?.recipients)
                if (self?.recipients.map{$0.id}.contains($0.id) == false) {
                    self?.recipients.append($0)
                }
            }
            .store(in: &subscriptions)
    }

    private func messageParameters() -> MessageParameters? {
        guard let courseID = selectedCourse?.courseId else { return nil }
        let recipientIDs = recipients.map { $0.id }

        return MessageParameters(
            subject: subject,
            body: bodyText,
            recipientIDs: recipientIDs,
            context: .course(courseID)
        )
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
        sendButtonDidTap
            //TODO: refactor
            .sink { [interactor, router] viewController in
                if let parameters = self.messageParameters() {
                    interactor
                        .send(parameters: parameters)
                        .sink { completion in
                            if case .failure(let error) = completion {
                                // error
                            } else {
                                performUIUpdate {
                                    router.dismiss(viewController)
                                }
                            }
                        }
                        .store(in: &self.subscriptions)
                }
            }
            .store(in: &subscriptions)
    }
}
