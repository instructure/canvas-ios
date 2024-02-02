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
    @Published public private(set) var recipients: [Recipient] = []
    @Published public private(set) var isSendingMessage: Bool = false

    @Published public private(set) var isContextDisabled: Bool = false
    @Published public private(set) var isRecipientsDisabled: Bool = false
    @Published public private(set) var isSubjectDisabled: Bool = false
    @Published public private(set) var isMessageDisabled: Bool = false
    @Published public private(set) var isIndividualDisabled: Bool = false

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
    public let recipientDidSelect = PassthroughRelay<Recipient>()
    public let recipientDidRemove = PassthroughRelay<Recipient>()
    public var selectedRecipients = CurrentValueSubject<[Recipient], Never>([])

    // MARK: - Inputs / Outputs
    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""
    @Published public var selectedContext: RecipientContext?
    @Published public var conversation: Conversation?
    @Published public var includedMessages: [ConversationMessage]?

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var messageType: ComposeMessageOptions.MessageType

    public init(router: Router, options: ComposeMessageOptions, interactor: ComposeMessageInteractor, scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler

        self.messageType = options.messageType
        setIncludedMessages(messageType: options.messageType)
        setOptionItems(options: options)

        setupOutputBindings()
        setupInputBindings(router: router)
    }

    private func setOptionItems(options: ComposeMessageOptions) {
        let disabledFields = options.disabledFields
        self.isContextDisabled = disabledFields.contextDisabled
        self.isRecipientsDisabled = disabledFields.recipientsDisabled
        self.isSubjectDisabled = disabledFields.subjectDisabled
        self.isMessageDisabled = disabledFields.messageDisabled
        self.isIndividualDisabled = disabledFields.individualDisabled

        let fieldContents = options.fieldContents
        self.selectedContext = fieldContents.selectedContext
        self.selectedRecipients.value = fieldContents.selectedRecipients
        self.subject = fieldContents.subjectText
        self.bodyText = fieldContents.bodyText
    }

    private func setIncludedMessages(messageType: ComposeMessageOptions.MessageType) {
        switch messageType {
        case .new:
            conversation = nil
        case .reply(let conversation, let message):
            self.conversation = conversation
            if let message {
                includedMessages = conversation.messages
                    .filter { $0.createdAt ?? Date() <= message.createdAt ?? Date() || $0.id == message.id }
            } else {
                includedMessages = conversation.messages
            }
        case .replyAll(let conversation, let message):
            self.conversation = conversation
            if let message {
                includedMessages = conversation.messages
                    .filter { $0.createdAt ?? Date() <= message.createdAt ?? Date() || $0.id == message.id }
            } else {
                includedMessages = conversation.messages
            }
        case .forward(let conversation, let message):
            if let message {
                includedMessages = [message]
            } else {
                includedMessages = conversation.messages
            }
            self.conversation = conversation
        }
    }

    public func courseSelectButtonDidTap(viewController: WeakViewController) {
        router.show(InboxCoursePickerAssembly.makeInboxCoursePickerViewController(selected: selectedContext) { [weak self] course in
            self?.courseDidSelect(selectedContext: course, viewController: viewController)
        }, from: viewController)
    }

    public func courseDidSelect(selectedContext: RecipientContext?, viewController: WeakViewController) {
        self.selectedContext = selectedContext
        selectedRecipients.value.removeAll()

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
        let addressbook = AddressBookAssembly.makeAddressbookRoleViewController(recipientContext: context, recipientDidSelect: recipientDidSelect, selectedRecipients: selectedRecipients)
        router.show(addressbook, from: viewController, options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true))
    }

    public func attachmentbuttonDidTap(viewController: WeakViewController) {

    }

    private func setupOutputBindings() {
        recipientDidSelect
            .sink { [weak self] recipient in
                if self?.selectedRecipients.value.contains(recipient) == true {
                    self?.recipientDidRemove.accept(recipient)
                } else {
                    self?.selectedRecipients.value.append(recipient)
                }
            }
            .store(in: &subscriptions)

        recipientDidRemove
            .sink { [weak self] recipient in
                self?.selectedRecipients.value.removeAll { $0 == recipient }
            }
            .store(in: &subscriptions)

        selectedRecipients
            .assign(to: &$recipients)
    }

    private func messageParameters() -> MessageParameters? {
        guard let context = selectedContext else { return nil }
        let recipientIDs = Array(Set(recipients.flatMap { $0.ids }))

        return MessageParameters(
            subject: subject,
            body: bodyText,
            recipientIDs: recipientIDs,
            context: context.context,
            conversationID: conversation?.id,
            groupConversation: !sendIndividual,
            includedMessages: includedMessages?.map { $0.id }
        )
    }

    private func showResultDialog(title: String, message: String, completion: (() -> Void)? = nil) {
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
            .compactMap { [weak self] viewController -> (WeakViewController, MessageParameters, ComposeMessageOptions.MessageType)? in
                guard let self = self, let params = self.messageParameters() else { return nil }
                return (viewController, params, self.messageType)
            }
            .handleEvents(receiveOutput: { [weak self] (viewController, _, _) in
                self?.isSendingMessage = true
                self?.router.dismiss(viewController)
            })
            .flatMap { [interactor] (viewController, params, type) in
                switch type {
                case .new:
                    return interactor
                        .createConversation(parameters: params)
                        .map {
                            viewController
                        }
                case .forward:
                    return interactor
                        .addConversationMessage(parameters: params)
                        .map {
                            viewController
                        }
                case .reply:
                    return interactor
                        .addConversationMessage(parameters: params)
                        .map {
                            viewController
                        }

                case .replyAll:
                    return interactor
                        .addConversationMessage(parameters: params)
                        .map {
                            viewController
                        }
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
