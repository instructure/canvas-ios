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

final class ComposeMessageViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var recipients: [Recipient] = []
    @Published public var isFilePickerVisible: Bool = false
    @Published public var isImagePickerVisible: Bool = false
    @Published public var isTakePhotoVisible: Bool = false
    @Published public var isAudioRecordVisible: Bool = false
    @Published public private(set) var state: InstUI.ScreenState = .data

    @Published public private(set) var isContextDisabled: Bool = false
    @Published public private(set) var isRecipientsDisabled: Bool = false
    @Published public private(set) var isSubjectDisabled: Bool = false
    @Published public private(set) var isMessageDisabled: Bool = false
    @Published public private(set) var isIndividualDisabled: Bool = false
    @Published public private(set) var isSendIndividualToggleDisabled: Bool = false
    @Published public var isShowingErrorDialog = false
    @Published private(set) var searchedRecipients: [Recipient] = []
    @Published public private(set) var expandedIncludedMessageIds = [String]()

    @Published public var showExtraSendButton = false
    public let screenConfig = InstUI.BaseScreenConfig(refreshable: false)
    public let title = String(localized: "[No Subject]", bundle: .core)
    public var sendButtonActive: Bool {
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
    public var didSelectFile = PassthroughRelay<(WeakViewController, URL?)>()
    public let didRemoveFile = PassthroughRelay<File>()

    // MARK: - Inputs / Outputs
    @Published var textRecipientSearch = ""
    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""
    @Published public var selectedContext: RecipientContext?
    @Published public var conversation: Conversation?
    @Published public var includedMessages: [ConversationMessage] = []
    @Published public var attachments: [File] = []
    @Published public var isShowingCancelDialog = false
    @Published var showSearchRecipientsView: Bool = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Unsaved Changes", bundle: .core),
        message: String(localized: "You have unsaved changes in your message. If you leave now, your current message will be lost.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Discard", bundle: .core),
        isDestructive: true
    )

    let errorAlert = ConfirmationAlertViewModel(
        title: String(localized: "Oops!", bundle: .core),
        message: String(localized: "This message could not be sent. Tap to try again.", bundle: .core),
        cancelButtonTitle: String(localized: "Back to editing", bundle: .core),
        confirmButtonTitle: String(localized: "Retry", bundle: .core),
        isDestructive: false
    )
    let router: Router

    // MARK: - Private
    private var initialMessageProperties = ComposeMessageProperties()
    private var changedMessageProperties = ComposeMessageProperties()
    private var didSentMailSuccessfully: PassthroughSubject<Void, Never>?
    public let didTapRetry = PassthroughRelay<WeakViewController>()
    private var viewController  = WeakViewController()
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let recipientInteractor: RecipientInteractor
    private let audioSession: AudioSessionProtocol
    private let cameraPermissionService: CameraPermissionService.Type
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var messageType: ComposeMessageOptions.MessageType
    private var allRecipients = CurrentValueSubject<[Recipient], Never>([])
    private var hiddenMessage: String = ""
    private var autoTeacherSelect: Bool = false
    private var teacherOnly: Bool = false
    private var sendIndividualToggleLastValue: Bool = false
    private let maxRecipientCount = 100

    // MARK: Public interface
    public init(
        router: Router,
        options: ComposeMessageOptions,
        interactor: ComposeMessageInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        recipientInteractor: RecipientInteractor,
        sentMailEvent: PassthroughSubject<Void, Never>? = nil,
        audioSession: AudioSessionProtocol,
        cameraPermissionService: CameraPermissionService.Type
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
        self.messageType = options.messageType
        self.recipientInteractor = recipientInteractor
        self.didSentMailSuccessfully = sentMailEvent
        self.audioSession = audioSession
        self.cameraPermissionService = cameraPermissionService
        setIncludedMessages(messageType: options.messageType)
        setOptionItems(options: options)

        setupOutputBindings()
        setupInputBindings(router: router)
        bindSearchRecipients()
    }

    private func getRecipients() {
        recipientInteractor
            .getRecipients(by: selectedContext?.context)
            .map { [selectedRecipients] values in
                values.filter { recipient in
                    !selectedRecipients.value.contains(where: { selectedRecipient in recipient == selectedRecipient })
                }
            }
            .sink { [weak self] result in
                self?.allRecipients.send(result)
            }
            .store(in: &subscriptions)
    }

    private func bindSearchRecipients() {
        Publishers.CombineLatest($textRecipientSearch.removeDuplicates(), allRecipients)
            .filter { (text, recipients) in
                text.trimmingCharacters(in: .whitespaces).count >= 3 && !recipients.isEmpty
            }
            .map { (text, recipients) in
                recipients.filter { $0.displayName.lowercased().contains(text.lowercased()) }
            }
            .assign(to: &$searchedRecipients)

        $searchedRecipients
            .map { !$0.isEmpty }
            .assign(to: &$showSearchRecipientsView)

        $textRecipientSearch
            .sink { [weak self] text in
                self?.searchedRecipients = text.count >= 3 ? (self?.searchedRecipients ?? []) : []
            }
            .store(in: &subscriptions)
    }

    // This func to hide the filer list recipients when tap on any place
    func clearSearchedRecipients() {
        searchedRecipients = []
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
        getRecipients()
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

    func addFiles(urls: [URL]) {
        urls.forEach { url in
            if url.startAccessingSecurityScopedResource() {
                addFile(url: url)
            }
        }
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
        sheet.title = String(localized: "Select Attachment Type", bundle: .core)

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
            guard let self else {
                return
            }
            VideoRecorder.requestPermission(cameraService: cameraPermissionService) { isEnabled in
                if isEnabled {
                    self.isTakePhotoVisible = true
                } else {
                    viewController.value.showPermissionError(.camera)
                }
            }
        }
        sheet.addAction(
            image: .audioLine,
            title: String(localized: "Record audio", bundle: .core),
            accessibilityIdentifier: nil
        ) { [weak self] in
            guard let self else {
                return
            }
            AudioRecorderViewController.requestPermission(audioSession: self.audioSession) { isEnabled in
                if isEnabled {
                    self.isAudioRecordVisible = true
                } else {
                    viewController.value.showPermissionError(.microphone)
                }
             }
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
                    self?.allRecipients.value.removeAll { $0 == recipient }
                }
            }
            .store(in: &subscriptions)

        didRemoveRecipient
            .sink { [weak self] recipient in
                self?.allRecipients.value.append(recipient)
                self?.selectedRecipients.value.removeAll { $0 == recipient }
            }
            .store(in: &subscriptions)

        selectedRecipients
            .assign(to: &$recipients)

        interactor.attachments
            .assign(to: &$attachments)

        $recipients
            .map { [maxRecipientCount] in
                $0.flatMap { $0.ids }.count > maxRecipientCount
            }
            .sink { [weak self] isExceedRecipientLimit in
                guard let self else {
                    return
                }
                self.isSendIndividualToggleDisabled = isExceedRecipientLimit
                if isExceedRecipientLimit {
                    self.sendIndividualToggleLastValue = self.sendIndividual
                    self.sendIndividual = true
                } else {
                    self.sendIndividual = sendIndividualToggleLastValue
                }
            }
            .store(in: &subscriptions)
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
        getRecipients()
        let extras = options.extras
        self.hiddenMessage = extras.hiddenMessage
        self.autoTeacherSelect = extras.autoTeacherSelect
        self.alwaysShowRecipients = extras.alwaysShowRecipients
        self.teacherOnly = extras.teacherOnly
        // Set initial Message Values so can check if there are any changes or not
        initialMessageProperties.courseName = selectedContext?.name
        initialMessageProperties.recipients = fieldContents.selectedRecipients
        initialMessageProperties.message = bodyText
        initialMessageProperties.subject = subject

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

        var body = bodyText.nilIfEmpty ?? String(localized: "[No message]", bundle: .core)
        if !hiddenMessage.isEmpty {
            body = "\(bodyText)\n\(hiddenMessage)"
        }

        if subject.isEmpty {
            subject = title
        }
        /// `bulkMessage` refers to:
        /// 1. Sending a message to a group or individuals.
        /// 2. Setting it to true if you are sending a message to more than 100 recipients.
        let isExceedsRecipientsLimit = recipientIDs.count > maxRecipientCount
        let bulkMessage = isExceedsRecipientsLimit ? true : sendIndividual
        return MessageParameters(
            subject: subject,
            body: body,
            recipientIDs: recipientIDs,
            attachmentIDs: attachments.compactMap { $0.id },
            context: context.context,
            conversationID: conversation?.id,
            bulkMessage: bulkMessage,
            includedMessages: includedMessages.map { $0.id }
        )
    }

    private func setupInputBindings(router: Router) {
        didTapCancel
            .handleEvents(receiveOutput: { [weak self] viewController in
                guard let self else {
                    return
                }
                if self.didApplyChanges() {
                    self.isShowingCancelDialog = true
                } else {
                    self.router.dismiss(viewController)
                }
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
                self?.state = .loading
                self?.viewController = viewController
            })
            .flatMap { [interactor] (viewController, params, type) in
                switch type {
                case .new:
                    return interactor
                        .createConversation(parameters: params)
                        .map { _ in
                            viewController
                        }
                        .replaceError(with: nil) // Replace the error to nil to avoid stop the pipeline(Publisher) in case error occurred for API so can make retry
                case .forward, .reply, .replyAll:
                    return interactor
                        .addConversationMessage(parameters: params)
                        .map { _ in
                            viewController
                        }
                        .replaceError(with: nil)
                }
            }
            .receive(on: scheduler)
            .sink(receiveValue: { [weak self] viewController in
                self?.state = .data
                if let viewController {
                    self?.didSendMessage(viewController: viewController)
                } else {
                    self?.didFailSendingMessage()
                }
            })
            .store(in: &subscriptions)
        didSelectFile.sink(receiveCompletion: { _ in }, receiveValue: { (controller, url) in
            guard let url else { return }
            router.route(
                to: url.appendingQueryItems(.init(name: "canEdit", value: "false")),
                from: controller,
                options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true)
            )
        })
        .store(in: &subscriptions)

        didRemoveFile
            .sink { [weak self] file in
                self?.interactor.removeFile(file: file)
            }
            .store(in: &subscriptions)

        didTapRetry
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isShowingErrorDialog = true
            })
            .flatMap { [errorAlert] value in
                errorAlert.userConfirmation().map { value }
            }
            .sink { [weak self] viewController in
                self?.didTapSend.accept(viewController)
            }
            .store(in: &subscriptions)
    }

    private func didSendMessage(viewController: WeakViewController) {
        didSentMailSuccessfully?.send()
        router.dismiss(viewController)
    }

    private func didFailSendingMessage() {
        Logger.shared.error("ComposeMessageView message failure")
        didTapRetry.accept(viewController)
    }

    private func didApplyChanges() -> Bool {
        changedMessageProperties.subject = subject
        changedMessageProperties.message = bodyText
        changedMessageProperties.files = attachments
        changedMessageProperties.courseName = selectedContext?.name
        changedMessageProperties.recipients = selectedRecipients.value
        return changedMessageProperties != initialMessageProperties
    }
}

// MARK: - Helpers
extension ComposeMessageViewModel {
    /// Using this type to match between the initial values and the changed values to
    /// show confirmation alert or not
    fileprivate struct ComposeMessageProperties: Equatable {
        var subject = ""
        var courseName: String?
        var message = ""
        var files: [File] = []
        var recipients: [Recipient] = []
    }
}
