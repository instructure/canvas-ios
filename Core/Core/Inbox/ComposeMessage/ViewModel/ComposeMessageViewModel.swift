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

    @Published public var isFilePickerVisible: Bool = false
    @Published public var isImagePickerVisible: Bool = false
    @Published public var isTakePhotoVisible: Bool = false
    @Published public var isAudioRecordVisible: Bool = false

    @Published public private(set) var isContextDisabled: Bool = false
    @Published public private(set) var isRecipientsDisabled: Bool = false
    @Published public private(set) var isSubjectDisabled: Bool = false
    @Published public private(set) var isMessageDisabled: Bool = false
    @Published public private(set) var isIndividualDisabled: Bool = false

    @Published public private(set) var expandedIncludedMessageIds = [String]()

    public let title = String(localized: "[No Subject]", bundle: .core)
    public var sendButtonActive: Bool {
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !recipients.isEmpty
        && (attachments.isEmpty || attachments.allSatisfy({ $0.isUploaded }))

    }

    private(set) var alwaysShowRecipients: Bool = false

    // MARK: - Inputs
    public let didTapSend = PassthroughRelay<WeakViewController>()
    public let didTapCancel = PassthroughRelay<WeakViewController>()
    public let didSelectRecipient = PassthroughRelay<Recipient>()
    public let didRemoveRecipient = PassthroughRelay<Recipient>()
    public var selectedRecipients = CurrentValueSubject<[Recipient], Never>([])
    public var didSelectFile = PassthroughRelay<(WeakViewController, File)>()
    public let didRemoveFile = PassthroughRelay<File>()

    // MARK: - Inputs / Outputs
    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""
    @Published public var selectedContext: RecipientContext?
    @Published public var conversation: Conversation?
    @Published public var includedMessages: [ConversationMessage] = []
    @Published public var attachments: [File] = []
    @Published public var isShowingCancelDialog = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Unsaved Changes", bundle: .core),
        message: String(localized: "You have unsaved changes in your message. If you leave now, your current message will be lost.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Discard", bundle: .core),
        isDestructive: true
    )
    let router: Router

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var messageType: ComposeMessageOptions.MessageType

    private var hiddenMessage: String = ""
    private var autoTeacherSelect: Bool = false
    private var teacherOnly: Bool = false

    // MARK: Public interface

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

    func courseSelectButtonDidTap(viewController: WeakViewController) {
        router.show(InboxCoursePickerAssembly.makeInboxCoursePickerViewController(selected: selectedContext) { [weak self] course in
            self?.courseDidSelect(selectedContext: course, viewController: viewController)
        }, from: viewController)
    }

    func courseDidSelect(selectedContext: RecipientContext?, viewController: WeakViewController) {
        self.selectedContext = selectedContext
        selectedRecipients.value.removeAll()

        if let context = selectedContext?.context, autoTeacherSelect {
            selectedRecipients.send([.init(id: "\(context.canvasContextID)_teachers", name: String(localized: "Teachers"), avatarURL: nil)])
        }

        closeCourseSelectorDelayed(viewController)
    }

    func addRecipientButtonDidTap(viewController: WeakViewController) {
        guard let context = selectedContext else { return }
        let addressbook = AddressBookAssembly.makeAddressbookRoleViewController(
            recipientContext: context,
            teacherOnly: teacherOnly,
            didSelectRecipient: didSelectRecipient,
            selectedRecipients: selectedRecipients)
        router.show(addressbook, from: viewController, options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true))
    }

    func attachmentButtonDidTap(viewController: WeakViewController) {
        showDialog(viewController: viewController)
    }

    func addFile(url: URL) {
        isImagePickerVisible = false
        isTakePhotoVisible = false
        isFilePickerVisible = false
        isAudioRecordVisible = false

        interactor.addFile(url: url)
    }

    func addFile(file: File) {
        interactor.addFile(file: file)
    }

    func isMessageExpanded(message: ConversationMessage) -> Bool {
        expandedIncludedMessageIds.contains(where: { $0 == message.id })
    }

    func toggleMessageExpand(message: ConversationMessage) {
        if isMessageExpanded(message: message) {
            expandedIncludedMessageIds.removeAll(where: { $0 == message.id })
        } else {
            expandedIncludedMessageIds.append(message.id)
        }
    }

    private func showDialog(viewController: WeakViewController) {
        let sheet = BottomSheetPickerViewController.create()

        sheet.addAction(
            image: .documentLine,
            title: String(localized: "Upload file", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isFilePickerVisible = true
        }
        sheet.addAction(
            image: .imageLine,
            title: String(localized: "Upload photo", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isImagePickerVisible = true
        }
        sheet.addAction(
            image: .cameraLine,
            title: String(localized: "Take photo", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isTakePhotoVisible = true
        }
        sheet.addAction(
            image: .audioLine,
            title: String(localized: "Record audio", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            self?.isAudioRecordVisible = true
        }
        sheet.addAction(
            image: .folderLine,
            title: String(localized: "Attach from Canvas files", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            guard let self, let top = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return }

            let viewController = AttachmentPickerAssembly.makeFilePickerViewController(env: .shared, onSelect: self.addFile)
            self.router.show(viewController, from: top, options: .modal(isDismissable: true, embedInNav: true))

        }
        router.show(sheet, from: viewController, options: .modal())
    }

    // MARK: Private helpers

    private func setupOutputBindings() {
        didSelectRecipient
            .sink { [weak self] recipient in
                if self?.selectedRecipients.value.contains(recipient) == true {
                    self?.didRemoveRecipient.accept(recipient)
                } else {
                    self?.selectedRecipients.value.append(recipient)
                }
            }
            .store(in: &subscriptions)

        didRemoveRecipient
            .sink { [weak self] recipient in
                self?.selectedRecipients.value.removeAll { $0 == recipient }
            }
            .store(in: &subscriptions)

        selectedRecipients
            .assign(to: &$recipients)

        interactor.attachments
            .assign(to: &$attachments)
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

        let extras = options.extras
        self.hiddenMessage = extras.hiddenMessage
        self.autoTeacherSelect = extras.autoTeacherSelect
        self.alwaysShowRecipients = extras.alwaysShowRecipients
        self.teacherOnly = extras.teacherOnly

        if autoTeacherSelect {
            selectedRecipients.send([.init(ids: [], name: String(localized: "Teachers"), avatarURL: nil)])
        }
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

    private func closeCourseSelectorDelayed(_ viewController: WeakViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let navController = viewController.value.navigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    private func messageParameters() -> MessageParameters? {
        guard let context = selectedContext else { return nil }
        let recipientIDs = Array(Set(recipients.flatMap { $0.ids }))

        var body = bodyText
        if !hiddenMessage.isEmpty {
            body = "\(bodyText)\n\(hiddenMessage)"
        }

        if subject.isEmpty {
            subject = title
        }

        return MessageParameters(
            subject: subject,
            body: body,
            recipientIDs: recipientIDs,
            attachmentIDs: attachments.compactMap { $0.id },
            context: context.context,
            conversationID: conversation?.id,
            groupConversation: !sendIndividual,
            includedMessages: includedMessages.map { $0.id }
        )
    }

    private func showResultDialog(title: String, message: String, completion: (() -> Void)? = nil) {
        let actionTitle = String(localized: "OK", bundle: .core)
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
        didTapCancel
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isShowingCancelDialog = true
            })
            .flatMap { [confirmAlert] value in
                confirmAlert.userConfirmation().map { value }
            }
            .sink { [weak self] viewController in
                self?.interactor.cancel()
                self?.router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        didTapSend
            .compactMap { [weak self] viewController -> (WeakViewController, MessageParameters, ComposeMessageOptions.MessageType)? in
                guard let self = self, let params = messageParameters() else { return nil }
                return (viewController, params, messageType)
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
                        .map { _ in
                            viewController
                        }
                case .forward, .reply, .replyAll:
                    return interactor
                        .addConversationMessage(parameters: params)
                        .map { _ in
                            viewController
                        }
                }
            }
            .receive(on: scheduler)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    Logger.shared.error("ComposeMessageView message failure")
                    let title = String(localized: "Message could not be sent", bundle: .core)
                    let message = String(localized: "Please try again!", bundle: .core)
                    self.showResultDialog(title: title, message: message)
                    self.isSendingMessage = false
                }
            }, receiveValue: { [weak self] _ in
                self?.isSendingMessage = false
            })
            .store(in: &subscriptions)

        didSelectFile.sink(receiveCompletion: { _ in }, receiveValue: { (controller, file) in
            guard let url = file.url, let fileController = router.match(url.appendingQueryItems(.init(name: "canEdit", value: "false"))) else { return }

            router.show(fileController, from: controller, options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true))
        })
        .store(in: &subscriptions)

        didRemoveFile
            .sink { [weak self] file in
                self?.interactor.removeFile(file: file)
            }
            .store(in: &subscriptions)
    }
}
