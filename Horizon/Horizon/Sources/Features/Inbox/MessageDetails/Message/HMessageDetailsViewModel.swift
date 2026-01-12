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
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
final class HMessageDetailsViewModel {
    // MARK: - Input / Outputs

    var reply: String = ""
    var isSending: Bool = false

    // MARK: - Outputs

    private(set) var messages: [HInboxMessageModel] = []
    private(set) var headerTitle: String = ""

    var attachmentItems: [AttachmentFileModel] {
        attachmentViewModel.items
    }
    var isSendDisabled: Bool {
        reply.trimmed().isEmpty || isSending || attachmentViewModel.isUploading
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var downloadCancellables: [String: AnyCancellable] = [:]

    // MARK: - Dependencies
    let attachmentViewModel: AttachmentViewModel
    private var conversation: Conversation?
    private let conversationID: String
    private let composeMessageInteractor: ComposeMessageInteractor
    private let downloadFileInteractor: DownloadFileInteractor
    private let userID: String
    private let messageDetailsInteractor: MessageDetailsInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Initialization
    init(
        conversationID: String,
        router: Router,
        userID: String,
        attachmentViewModel: AttachmentViewModel,
        messageDetailsInteractor: MessageDetailsInteractor,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor,
        allowArchive: Bool,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.conversationID = conversationID
        self.router = router
        self.userID = userID
        self.messageDetailsInteractor = messageDetailsInteractor
        self.composeMessageInteractor = composeMessageInteractor
        self.downloadFileInteractor = downloadFileInteractor
        self.attachmentViewModel = attachmentViewModel
        self.scheduler = scheduler
        markConversationAsRead()

        messageDetailsInteractor.conversation.sink { [weak self] conversations in
            self?.conversation = conversations.first { $0.id == conversationID }

        }
        .store(in: &subscriptions)

        listenForMessages()
        listenForSubject()
    }

    // MARK: - Inputs

    func attachFile(viewController: WeakViewController) {
        attachmentViewModel.isVisible = true
    }

    func pop(viewController: WeakViewController) {
        attachmentViewModel.deleteAll()
        router.pop(from: viewController)
    }

    func refresh(finish: (() -> Void)? = nil) {
        messageDetailsInteractor
            .refresh()
            .sink { finish?() }
            .store(in: &subscriptions)
    }

    func sendMessage(viewController: WeakViewController) {
        let reply = reply.trimmed()
        guard let conversation = conversation, reply.isNotEmpty else { return }
        isSending = true
        let recipientIDs = messageDetailsInteractor.userMap.map { $0.key }.filter { $0 != self.userID }
        let attachmentIDs = attachmentViewModel.items.compactMap { $0.id }
        composeMessageInteractor.addConversationMessage(
            parameters: MessageParameters(
                subject: conversation.subject,
                body: reply,
                recipientIDs: recipientIDs,
                attachmentIDs: attachmentIDs,
                conversationID: conversation.id,
                bulkMessage: true,
                includedMessages: messageDetailsInteractor.messages.value.map { $0.id }
            )
        )
        .receive(on: scheduler)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] _ in
                self?.isSending = false
                self?.reply = ""
                self?.composeMessageInteractor.attachments.send([])
            }
        )
        .store(in: &self.subscriptions)
    }

    // MARK: - Private Methods

    private func listenForMessages() {
        messageDetailsInteractor
            .messages
            .map { messages in
                messages.sorted { $0.createdAt ?? .distantPast < $1.createdAt ?? .distantPast }
            }
            .sink { [weak self] sortedMessages in
                guard let self = self else { return }
                let userMap = self.messageDetailsInteractor.userMap
                self.messages = sortedMessages.toHInboxMessageModels(
                    router: router,
                    userID: userID,
                    userMap: userMap
                )
            }
            .store(in: &subscriptions)
    }

    private func listenForSubject() {
        messageDetailsInteractor.conversation.sink { [weak self] conversations in
            self?.headerTitle = conversations.first { $0.id == self?.conversationID }?.subject ?? String(localized: "Conversation", bundle: .horizon)
        }
        .store(in: &subscriptions)
    }

    private func markConversationAsRead() {
        messageDetailsInteractor
            .updateState(messageId: conversationID, state: .read)
            .sink()
            .store(in: &subscriptions)
    }

    func startDownload(
        messageID: String,
        attachment: AttachmentFileModel,
        viewController: WeakViewController
    ) {
        setAttachmentDownloading(messageID: messageID, attachmentID: attachment.id)
        performDownload(messageID: messageID, attachment: attachment, viewController: viewController)
    }

    func cancelDownload(
        messageID: String,
        attachment: AttachmentFileModel
    ) {
        let attachmentID = attachment.id
        setAttachmentFinished(messageID: messageID, attachmentID: attachmentID)
    }

    private func removeCancellable(for attachmentID: String) {
        downloadCancellables[attachmentID]?.cancel()
        downloadCancellables.removeValue(forKey: attachmentID)
    }
    private func performDownload(
        messageID: String,
        attachment: AttachmentFileModel,
        viewController: WeakViewController
    ) {

        guard downloadCancellables[attachment.id] == nil else { return }

        let cancellable = downloadFileInteractor
            .download(file: attachment.file)
            .receive(on: scheduler)
            .sinkFailureOrValue(
                receiveFailure: { [weak self] _ in
                    self?.setAttachmentFinished(
                        messageID: messageID,
                        attachmentID: attachment.id
                    )
                },
                receiveValue: { [weak self] url in
                    self?.setAttachmentFinished(
                        messageID: messageID,
                        attachmentID: attachment.id
                    )
                    self?.router.showShareSheet(fileURL: url, viewController: viewController)
                }
            )
        downloadCancellables[attachment.id] = cancellable
    }

    private func setAttachmentDownloading(
        messageID: String,
        attachmentID: String
    ) {
        updateAttachment(messageID: messageID, attachmentID: attachmentID) {
            var updated = $0
            updated.startDownloading()
            return updated
        }
    }

    private func setAttachmentFinished(
        messageID: String,
        attachmentID: String
    ) {
        removeCancellable(for: attachmentID)
        updateAttachment(messageID: messageID, attachmentID: attachmentID) {
            var updated = $0
            updated.finishDownloading()
            return updated
        }
    }

    private func updateAttachment(
        messageID: String,
        attachmentID: String,
        transform: (AttachmentFileModel) -> AttachmentFileModel
    ) {
        messages = messages.map { message in
            guard message.id == messageID else { return message }

            let updatedAttachments = message.attachments.map { attachment in
                guard attachment.id == attachmentID else { return attachment }
                return transform(attachment)
            }

            return HInboxMessageModel(
                attachments: updatedAttachments,
                author: message.author,
                body: message.body,
                date: message.date,
                id: message.id,
                isAnnouncement: message.isAnnouncement
            )
        }
    }
}
