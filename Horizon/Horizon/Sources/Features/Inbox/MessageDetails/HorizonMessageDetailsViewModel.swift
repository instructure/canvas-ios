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

@Observable
class HorizonMessageDetailsViewModel {
    // MARK: - Outputs
    var attachmentItems: [AttachmentItemViewModel] {
        attachmentViewModel?.items ?? []
    }
    var isSendDisabled: Bool {
        reply.isEmpty || isSending || attachmentViewModel?.isUploading ?? false
    }
    var reply: String = ""
    var sendButtonOpacity: Double {
        isSending ? (attachmentViewModel?.isUploading == true ? 0.5 : 0.0) : 1.0
    }
    var loadingSpinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }
    private(set) var messagesAsc: [MessageViewModel] = []
    var isReplayAreaVisible: Bool = true
    private(set) var headerTitle: String = ""

    // MARK: - Private
    private var isSending: Bool = false
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let announcementID: String
    let attachmentViewModel: AttachmentViewModel?
    private var conversation: Conversation?
    private let conversationID: String?
    private let composeMessageInteractor: ComposeMessageInteractor?
    private var isMarkedAsRead = false
    private let myID: String
    private let messageDetailsInteractor: MessageDetailsInteractor?
    private let router: Router
    private let announcementsInteractor: AnnouncementsInteractor?

    // MARK: - Initialization
    init(
        conversationID: String,
        router: Router = AppEnvironment.shared.router,
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
        self.announcementsInteractor = nil
        self.announcementID = ""

        messageDetailsInteractor.conversation.sink { [weak self] conversations in
            self?.conversation = conversations.first { $0.id == conversationID }
        }
        .store(in: &subscriptions)

        listenForMessages()
        listenForSubject()
    }

    init(
        announcementID: String,
        announcement: Announcement? = nil,
        environment: AppEnvironment = AppEnvironment.shared,
        router: Router = AppEnvironment.shared.router,
        announcementsInteractor: AnnouncementsInteractor = AnnouncementsInteractorLive(),
        myID: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.announcementID = announcementID
        self.router = router
        self.announcementsInteractor = announcementsInteractor
        self.myID = myID

        self.attachmentViewModel = nil
        self.messageDetailsInteractor = nil
        self.composeMessageInteractor = nil
        self.conversationID = nil
        self.isReplayAreaVisible = false

        if let announcement = announcement {
            self.headerTitle = announcement.title
            self.messagesAsc = [
                MessageViewModel(
                    id: announcement.id,
                    body: announcement.title,
                    author: announcement.courseName ?? "",
                    date: announcement.date?.dateTimeString ?? "",
                    avatarName: ""
                )
            ]
        } else {
            listenForAnnouncements()
            listenForSubject()
        }
    }

    // MARK: - Inputs
    func attachFile(viewController: WeakViewController) {
        attachmentViewModel?.show(from: viewController)
    }

    func pop(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func refresh(finish: (() -> Void)? = nil) {
        messageDetailsInteractor?
            .refresh()
            .sink { finish?() }
            .store(in: &subscriptions) ?? finish?()
    }

    func sendMessage(viewController: WeakViewController) {
        guard let conversation = conversation,
              let composeMessageInteractor = self.composeMessageInteractor,
              let messageDetailsInteractor = self.messageDetailsInteractor else {
            return
        }

        isSending = true
        Task { [weak self] in
            guard let self = self else {
                return
            }
            let recipientIDs = messageDetailsInteractor.userMap.map { $0.key }.filter { $0 != self.myID }
            composeMessageInteractor.addConversationMessage(
                parameters: MessageParameters(
                    subject: conversation.subject,
                    body: self.reply,
                    recipientIDs: recipientIDs,
                    attachmentIDs: attachmentViewModel?.items.map { $0.id } ?? [],
                    conversationID: conversation.id,
                    bulkMessage: true
                )
            ).sink(
                receiveCompletion: { _ in
                    performUIUpdate {
                        self.isSending = false
                        self.reply = ""
                        self.composeMessageInteractor?.cancel()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &self.subscriptions)
        }
    }

    // MARK: - Private Methods
    private func listenForAnnouncements() {
        announcementsInteractor?.messages.sink { [weak self] announcements in
            self?.headerTitle = announcements.first(where: { $0.id == self?.announcementID })?.title ?? String(localized: "Announcement", bundle: .horizon)
            self?.messagesAsc = announcements
                .filter { $0.id == self?.announcementID }
                .map { announcement in
                    MessageViewModel(
                        id: announcement.id,
                        body: announcement.title,
                        author: announcement.author,
                        date: announcement.date?.dateTimeString ?? "",
                        avatarName: ""
                    )
                }
        }
        .store(in: &subscriptions)
    }

    private func listenForMessages() {
        messageDetailsInteractor?
            .messages
            .map(markMessageAsRead)
            .map(sortOldestToNewest)
            .map(toViewModels)
            .sink { [weak self] conversationMessages in
                guard let self = self else { return }
                self.messagesAsc = conversationMessages
            }
            .store(in: &subscriptions)
    }

    private func listenForSubject() {
        announcementsInteractor?.messages.sink { [weak self] announcements in
            let announcementTitle = announcements.first(where: { $0.id == self?.announcementID })?.title
            self?.headerTitle = announcementTitle ?? String(localized: "Announcement", bundle: .horizon)
        }
        .store(in: &subscriptions)

        messageDetailsInteractor?.conversation.sink { [weak self] conversations in
            self?.headerTitle = conversations.first { $0.id == self?.conversationID }?.subject ?? String(localized: "Conversation", bundle: .horizon)
        }
        .store(in: &subscriptions)
    }

    private func markMessageAsRead(_ conversationMessages: [ConversationMessage]) -> [ConversationMessage] {
        if let conversationID = conversationID, isMarkedAsRead == false {
            messageDetailsInteractor?.updateState(
                messageId: conversationID,
                state: .read
            )
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &self.subscriptions)
            isMarkedAsRead = true
        }

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
                userMap: messageDetailsInteractor?.userMap ?? [:],
                router: router
            )
        }
    }
}

extension HorizonMessageDetailsViewModel {
    convenience init(
        announcement: Announcement,
        environment: AppEnvironment = AppEnvironment.shared,
        router: Router = AppEnvironment.shared.router,
        announcementsInteractor: AnnouncementsInteractor = AnnouncementsInteractorLive(),
        myID: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.init(
            announcementID: announcement.id,
            environment: environment,
            router: router,
            announcementsInteractor: announcementsInteractor,
            myID: myID
        )
        // Initialize properties from Announcement
        self.messagesAsc = [
            MessageViewModel(
                id: announcement.id,
                body: announcement.title,
                author: announcement.courseName ?? "",
                date: announcement.date?.dateTimeString ?? "",
                avatarName: ""
            )
        ]
        self.isReplayAreaVisible = false
    }
}
