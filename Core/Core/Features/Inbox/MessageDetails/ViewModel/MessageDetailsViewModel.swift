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
import Foundation

class MessageDetailsViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var subject: String = ""
    @Published public private(set) var messages: [MessageViewModel] = []
    @Published public private(set) var conversations: [Conversation] = []
    @Published public private(set) var starred: Bool = false
    @Published public private(set) var isReplyButtonVisible: Bool = false
    public let snackBarViewModel = SnackBarViewModel()

    public let title = String(localized: "Message Details", bundle: .core)

    @Published public var isShowingCancelDialog = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Are you sure?", bundle: .core),
        message: String(localized: "It will permanently delete this message from your profile.", bundle: .core),
        cancelButtonTitle: String(localized: "No", bundle: .core),
        confirmButtonTitle: String(localized: "Yes", bundle: .core),
        isDestructive: false
    )

    // MARK: - Inputs
    public let refreshDidTrigger = PassthroughSubject<() -> Void, Never>()
    public let starDidTap = PassthroughSubject<Bool, Never>()
    public let deleteConversationDidTap = PassthroughSubject<(conversationId: String, viewController: WeakViewController), Never>()
    public let deleteConversationMessageDidTap = PassthroughSubject<(conversationId: String, messageId: String, viewController: WeakViewController), Never>()
    public let updateState = PassthroughSubject<ConversationWorkflowState, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: MessageDetailsInteractor
    private let env: AppEnvironment
    private let myID: String
    private let allowArchive: Bool

    public init(interactor: MessageDetailsInteractor, myID: String, allowArchive: Bool, env: AppEnvironment) {
        self.interactor = interactor
        self.myID = myID
        self.allowArchive = allowArchive
        self.env = env

        setupOutputBindings()
        setupInputBindings()
    }

    public func conversationMoreTapped(viewController: WeakViewController) {
        let sheet = BottomSheetPickerViewController.create()
       if isReplyButtonVisible {
           addReplyAction(sheet) { [weak self] in
               self?.replyTapped(message: nil, viewController: viewController)
           }

           addReplyAllAction(sheet) { [weak self] in
               self?.replyAllTapped(message: nil, viewController: viewController)

           }
        }

        sheet.addAction(
            image: .forwardLine,
            title: String(localized: "Forward", bundle: .core),
            accessibilityIdentifier: "MessageDetails.forward"
        ) { [weak self] in
            self?.forwardTapped(message: nil, viewController: viewController)
        }

        if (conversations.first?.workflowState == .read) {
            sheet.addAction(
                image: .nextUnreadLine,
                title: String(localized: "Mark as Unread", bundle: .core),
                accessibilityIdentifier: "MessageDetails.markAsUnread"
            ) { [weak self] in
                self?.updateState.send(.unread)
            }
        } else {
            sheet.addAction(
                image: .emailLine,
                title: String(localized: "Mark as Read", bundle: .core),
                accessibilityIdentifier: "MessageDetails.markAsRead"
            ) { [weak self] in
                self?.updateState.send(.read)
            }
        }

        if conversations.first?.workflowState != .archived, allowArchive {
            sheet.addAction(
                image: .archiveLine,
                title: String(localized: "Archive", bundle: .core),
                accessibilityIdentifier: "MessageDetails.archive"
            ) { [weak self] in
                self?.updateState.send(.archived)
            }
        }

        if conversations.first?.workflowState == .archived, allowArchive {
            sheet.addAction(
                image: .unarchiveLine,
                title: String(localized: "Unarchive", bundle: .core),
                accessibilityIdentifier: "MessageDetails.unarchive"
            ) { [weak self] in
                self?.updateState.send(.read)
            }
        }

        sheet.addAction(
            image: .trashLine,
            title: String(localized: "Delete Conversation", bundle: .core),
            accessibilityIdentifier: "MessageDetails.delete"
        ) { [weak self] in
            if let conversationId = self?.conversations.first?.id {
                self?.deleteConversationDidTap.send((conversationId, viewController))
            }
        }
        env.router.show(sheet, from: viewController, options: .modal())
    }

    public func messageMoreTapped(message: ConversationMessage?, viewController: WeakViewController) {
        let sheet = BottomSheetPickerViewController.create()
        if isReplyButtonVisible {
            addReplyAction(sheet) { [weak self] in
                if let message {
                    self?.replyTapped(message: message, viewController: viewController)
                }
            }

            addReplyAllAction(sheet) { [weak self] in
                if let message {
                    self?.replyAllTapped(message: message, viewController: viewController)
                }
            }
        }

        sheet.addAction(
            image: .forwardLine,
            title: String(localized: "Forward", bundle: .core),
            accessibilityIdentifier: "MessageDetails.forward"
        ) { [weak self] in
            self?.forwardTapped(message: message, viewController: viewController)
        }

        sheet.addAction(
            image: .trashLine,
            title: String(localized: "Delete Message", bundle: .core),
            accessibilityIdentifier: "MessageDetails.delete"
        ) { [weak self] in
            if let conversationId = self?.conversations.first?.id, let messageId = message?.id {
                self?.deleteConversationMessageDidTap.send((conversationId: conversationId, messageId: messageId, viewController: viewController))
            }
        }
        env.router.show(sheet, from: viewController, options: .modal())
    }

    private func addReplyAction(_ sheet: BottomSheetPickerViewController, action: @escaping () -> Void ) {
        sheet.addAction(
            image: .replyLine,
            title: String(localized: "Reply", bundle: .core),
            accessibilityIdentifier: "MessageDetails.reply", action: action)
    }

    private func addReplyAllAction(_ sheet: BottomSheetPickerViewController, action: @escaping () -> Void ) {
        sheet.addAction(
            image: .replyAllLine,
            title: String(localized: "Reply All", bundle: .core),
            accessibilityIdentifier: "MessageDetails.replyAll", action: action)
    }

    public func forwardTapped(message: ConversationMessage? = nil, viewController: WeakViewController) {
        if let conversation = conversations.first {
            env.router.show(
                ComposeMessageAssembly.makeComposeMessageViewController(
                    options: .init(
                        fromType: .forward(conversation: conversation, message: message)
                    ),
                    env: env
                ),
                from: viewController,
                options: .modal(
                    .automatic,
                    isDismissable: false,
                    embedInNav: true,
                    addDoneButton: false,
                    animated: true
                ))
        }
    }

    public func replyTapped(message: ConversationMessage?, viewController: WeakViewController) {
        if let conversation = conversations.first {
            env.router.show(
                ComposeMessageAssembly.makeComposeMessageViewController(options: .init(fromType: .reply(conversation: conversation, message: message)), env: env),
                from: viewController,
                options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
            )
        }
    }

    public func replyAllTapped(message: ConversationMessage?, viewController: WeakViewController) {
        if let conversation = conversations.first {
            env.router.show(
                ComposeMessageAssembly.makeComposeMessageViewController(options: .init(fromType: .replyAll(conversation: conversation, message: message)), env: env),
                from: viewController,
                options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
            )
        }
    }

    private func setupOutputBindings() {
        interactor.state
                .assign(to: &$state)
        interactor.subject
            .assign(to: &$subject)

        interactor.conversation
            .map { [weak self] in
                self?.isReplyButtonVisible = !($0.first?.cannotReply ?? false)
                return $0
            }
            .assign(to: &$conversations)
        interactor.messages
            .map { messages in
                messages.map {
                    MessageViewModel(item: $0, myID: self.myID, userMap: self.interactor.userMap, router: self.env.router)
                }
            }
            .assign(to: &$messages)
        interactor.starred
            .assign(to: &$starred)
    }

    private func setupInputBindings() {
        let interactor = self.interactor
        refreshDidTrigger
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .flatMap { refreshCompletion in
                interactor
                    .refresh()
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveOutput: { refreshCompletion() })
            }
            .sink()
            .store(in: &subscriptions)

        starDidTap
            .map { starred in
                interactor.updateStarred(starred: starred) }
            .sink()
            .store(in: &subscriptions)

        updateState
            .compactMap { [weak self] state -> (messageId: String, state: ConversationWorkflowState)? in
                if let messageId = self?.conversations.first?.id {
                    return (messageId: messageId, state: state)
                } else {
                    return nil
                }
            }
            .map { interactor.updateState(messageId: $0.messageId, state: $0.state) }
            .sink()
            .store(in: &subscriptions)

        deleteConversationDidTap
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isShowingCancelDialog = true
            })
            .flatMap { [confirmAlert] value in
                confirmAlert.userConfirmation().map { value }
            }
            .sink { [weak self] (conversationId, viewController) in
                if let self {
                    interactor.deleteConversation(conversationId: conversationId)
                        .sink()
                        .store(in: &subscriptions)
                }
                self?.env.router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        deleteConversationMessageDidTap
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isShowingCancelDialog = true
            })
            .flatMap { [confirmAlert] value in
                confirmAlert.userConfirmation().map { value }
            }
            .sink { [weak self] (conversationId, messageId, viewController) in
                if let self {
                    interactor.deleteConversationMessage(conversationId: conversationId, messageId: messageId)
                        .sink()
                        .store(in: &subscriptions)
                }
                if self?.messages.count ?? 0 <= 1 {
                    self?.env.router.dismiss(viewController)
                }
                self?.refreshDidTrigger.send({ })
            }
            .store(in: &subscriptions)
    }
}
