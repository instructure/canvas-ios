//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import SwiftUI

class HorizonMessageDetailsViewModel: MessageDetailsViewModel {
    // MARK: - Outputs
    var attachmentItems: [AttachmentItemViewModel] {
        attachmentViewModel.items
    }
    var isSendDisabled: Bool {
        reply.isEmpty || isSending || attachmentViewModel.isUploading
    }
    @Published var reply: String = ""
    var sendButtonOpacity: Double {
        isSending ? (attachmentViewModel.isUploading ? 0.5 : 0.0) : 1.0
    }
    var loadingSpinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }
    @Published public private(set) var messagesAscending: [MessageViewModel] = []

    // MARK: - Private
    private var isSending: Bool = false
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    let attachmentViewModel: AttachmentViewModel
    private let conversationID: String
    private let composeMessageInteractor: ComposeMessageInteractor
    private let messageDetailsInteractor: MessageDetailsInteractor
    private let myID: String
    private let router: Router

    // MARK: - Initialization
    init(
        router: Router = AppEnvironment.shared.router,
        conversationID: String,
        attachmentViewModel: AttachmentViewModel? = nil,
        messageDetailsInteractor: MessageDetailsInteractor,
        composeMessageInteractor: ComposeMessageInteractor,
        myID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        allowArchive: Bool
    ) {
        self.router = router
        self.conversationID = conversationID
        self.attachmentViewModel = attachmentViewModel ?? AttachmentViewModel(
            router: router,
            composeMessageInteractor: composeMessageInteractor
        )
        self.messageDetailsInteractor = messageDetailsInteractor
        self.composeMessageInteractor = composeMessageInteractor
        self.myID = myID
        super.init(
            router: router,
            interactor: messageDetailsInteractor,
            myID: myID,
            allowArchive: allowArchive
        )

        listenForMessages()
    }

    // MARK: - Inputs
    func attachFile(viewController: WeakViewController) {
        attachmentViewModel.show(from: viewController)
    }

    func pop(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func refresh(finish: (() -> Void)? = nil) {
        messageDetailsInteractor
            .refresh()
            .sink { finish?() }
            .store(in: &subscriptions)
    }

    func sendMessage(viewController: WeakViewController) {
        guard let conversation = conversations.first,
              let contextCode = conversation.contextCode,
              let context = Context(canvasContextID: contextCode) else {
            return
        }

        isSending = true
        Task { [weak self] in
            guard let self = self else {
                return
            }
            let recipientIDs = self.messageDetailsInteractor.userMap.map { $0.key }.filter { $0 != self.myID }
            self.composeMessageInteractor.addConversationMessage(
                parameters: MessageParameters(
                    subject: conversation.subject,
                    body: self.reply,
                    recipientIDs: recipientIDs,
                    attachmentIDs: [],
                    context: context,
                    conversationID: conversation.id,
                    bulkMessage: true
                )
            ).sink(
                receiveCompletion: { _ in
                    performUIUpdate {
                        self.isSending = false
                        self.reply = ""
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &self.subscriptions)
        }
    }

    // MARK: - Private Methods
    private func listenForMessages() {
        messageDetailsInteractor
            .messages
            .map(markMessageAsRead)
            .map(sortOldestToNewest)
            .map(toViewModels)
            .assign(to: &$messagesAscending)
    }

    private func markMessageAsRead(_ conversationMessages: [ConversationMessage]) -> [ConversationMessage] {
        messageDetailsInteractor.updateState(
            messageId: conversationID,
            state: .read
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        .store(in: &self.subscriptions)

        return conversationMessages
    }

    private func sortOldestToNewest(_ conversationMessages: [ConversationMessage]) -> [ConversationMessage] {
        conversationMessages.sorted { $0.createdAt ?? .distantPast < $1.createdAt ?? .distantPast }
    }

    private func toViewModels(_ conversationMessages: [ConversationMessage]) -> [MessageViewModel] {
        conversationMessages.map {
            MessageViewModel(
                item: $0,
                myID: myID,
                userMap: messageDetailsInteractor.userMap,
                router: router
            )
        }
    }
}
