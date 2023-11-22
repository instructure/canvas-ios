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
import CombineSchedulers

class ComposeMessageViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var courses: [InboxCourse] = []
    @Published public private(set) var recipients: [SearchRecipient] = []
    @Published public private(set) var isSendingMessage: Bool = false

    public let title = NSLocalizedString("New Message", comment: "")
    public var sendButtonActive: Bool {
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !recipients.isEmpty
        // && (attachments.isEmpty || attachments.allSatisfy({ $0.isUploaded }))

    }

    // MARK: - Inputs
    public let sendButtonDidTap = PassthroughRelay<WeakViewController>()
    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let addRecipientButtonDidTap = PassthroughRelay<WeakViewController>()
    public let selectedRecipient = CurrentValueRelay<[SearchRecipient]>([])

    // MARK: - Inputs / Outputs
    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""
    @Published public var selectedContext: RecipientContext?

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public init(router: Router, interactor: ComposeMessageInteractor, scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler

        setupOutputBindings()
        setupInputBindings(router: router)
    }

    public func courseSelectButtonDidTap(viewController: WeakViewController) {
        router.show(InboxCoursePickerAssembly.makeInboxCoursePickerViewController(selected: selectedContext) { [weak self] course in
            self?.courseDidSelect(selectedContext: course, viewController: viewController)
        }, from: viewController)
    }

    private func courseDidSelect(selectedContext: RecipientContext?, viewController: WeakViewController) {
        self.selectedContext = selectedContext
        recipients.removeAll()

        closeCourseSelectorDelayed(viewController)
    }

    private func closeCourseSelectorDelayed(_ viewController: WeakViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let navController = viewController.value.navigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    public func addRecipientButtonDidTap(viewController: WeakViewController) {
        guard let context = selectedContext else { return }
        let addressbook = AddressBookAssembly.makeAddressbookRoleViewController(recipientContext: context, recipientDidSelect: selectedRecipient)
        router.show(addressbook, from: viewController, options: .modal(.automatic, isDismissable: true, embedInNav: true, addDoneButton: false, animated: true))
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
            .sink { [weak self] in
                let ids = self?.recipients.map { $0.id } ?? []
                $0.forEach { recipient in
                    if !ids.contains(recipient.id) {
                        self?.recipients.append(recipient)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func messageParameters() -> MessageParameters? {
        guard let context = selectedContext else { return nil }
        let recipientIDs = recipients.map { $0.id }

        return MessageParameters(
            subject: subject,
            body: bodyText,
            recipientIDs: recipientIDs,
            context: context.context
        )
    }

    private func showResultDialog(title: String, message: String, completion: (() -> Void)? = nil) {
        let title = NSLocalizedString(title, comment: "")
        let message = NSLocalizedString(message, comment: "")
        let actionTitle = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            completion?()
        }
        alert.addAction(action)

        if let top = AppEnvironment.shared.window?.rootViewController {
            router.show(alert, from: top, options: .modal())
        }
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
        sendButtonDidTap
            .compactMap { [weak self] viewController -> (WeakViewController, MessageParameters)? in
                guard let self = self, let params = self.messageParameters() else { return nil }
                return (viewController, params)
            }
            .handleEvents(receiveOutput: { [weak self] (viewController, _) in
                self?.isSendingMessage = true
                self?.router.dismiss(viewController)
            })
            .flatMap { [interactor] (viewController, params) in
                interactor
                    .send(parameters: params)
                    .map {
                        viewController
                    }
            }
            .receive(on: scheduler)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    Logger.shared.error("ComposeMessageView message failure")
                    let title = NSLocalizedString("Message could not be sent", comment: "")
                    let message = NSLocalizedString("Please try again!", comment: "")
                    self.showResultDialog(title: title, message: message)
                    self.isSendingMessage = false
                }
            }, receiveValue: { [weak self] _ in
                self?.isSendingMessage = false
            })
            .store(in: &subscriptions)
    }
}
