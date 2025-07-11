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
class HMessageDetailsViewModel {
    // MARK: - Outputs
    var attachmentItems: [AttachmentItemViewModel] {
        attachmentViewModel?.items ?? []
    }
    var dismissKeyboard: (() -> Void)?
    var isAnimationEnabled: Bool = false
    var isAnnouncementIconVisible: Bool {
        announcementID != nil
    }
    var isAttachmentsListScrollViewVisible: Bool {
        (attachmentViewModel?.items.count ?? 0) > 3
    }
    var isSendDisabled: Bool {
        reply.trimmed().isEmpty || isSending || attachmentViewModel?.isUploading ?? false
    }
    var reply: String = ""
    var sendButtonOpacity: Double {
        isSending ? (attachmentViewModel?.isUploading == true ? 0.5 : 0.0) : 1.0
    }
    var loadingSpinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }
    private(set) var messages: [HMessageViewModel] = []
    var isReplayAreaVisible: Bool = true
    private(set) var headerTitle: String = ""

    // MARK: - Private
    private var isSending: Bool = false
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let announcementsInteractor: AnnouncementsInteractor?
    private let announcementID: String?
    let attachmentViewModel: AttachmentViewModel?
    private var conversation: Conversation?
    private let conversationID: String?
    private let composeMessageInteractor: ComposeMessageInteractor?
    private let downloadFileInteractor: DownloadFileInteractor?
    private var isMarkedAsRead = false
    private let myID: String
    private let messageDetailsInteractor: MessageDetailsInteractor?
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Initialization
    init(
        conversationID: String,
        router: Router = AppEnvironment.shared.router,
        attachmentViewModel: AttachmentViewModel? = nil,
        messageDetailsInteractor: MessageDetailsInteractor,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor = DownloadFileInteractorLive(),
        myID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        allowArchive: Bool,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.conversationID = conversationID
        self.attachmentViewModel = attachmentViewModel ?? AttachmentViewModel(
            router: router,
            composeMessageInteractor: composeMessageInteractor
        )
        self.messageDetailsInteractor = messageDetailsInteractor
        self.composeMessageInteractor = composeMessageInteractor
        self.downloadFileInteractor = downloadFileInteractor
        self.myID = myID
        self.announcementsInteractor = nil
        self.announcementID = nil
        self.scheduler = scheduler

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
        myID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.announcementID = announcementID
        self.router = router
        self.announcementsInteractor = announcementsInteractor
        self.myID = myID
        self.scheduler = scheduler

        self.attachmentViewModel = nil
        self.messageDetailsInteractor = nil
        self.composeMessageInteractor = nil
        self.downloadFileInteractor = nil
        self.conversationID = nil
        self.isReplayAreaVisible = false

        if let announcement = announcement {
            self.headerTitle = announcement.title
            self.messages = [.init(announcement: announcement)]
        } else {
            listenForAnnouncements()
            listenForSubject()
        }
    }

    // MARK: - Inputs
    func attachFile(viewController: WeakViewController) {
        attachmentViewModel?.isVisible = true
    }

    func onScroll() {
        dismissKeyboard?()
    }

    func onTextAreaFocusChange(_ isFocused: Bool) {
        if !isFocused {
            reply = reply.trimmed()
        }
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
        let reply = reply.trimmed()
        guard let conversation = conversation,
              let composeMessageInteractor = self.composeMessageInteractor,
              let messageDetailsInteractor = self.messageDetailsInteractor,
              reply.isNotEmpty else {
            return
        }
        isSending = true
        let recipientIDs = messageDetailsInteractor.userMap.map { $0.key }.filter { $0 != self.myID }
        let attachmentIDs = attachmentViewModel?.items.compactMap { $0.id } ?? []
        composeMessageInteractor.addConversationMessage(
            parameters: MessageParameters(
                subject: conversation.subject,
                body: reply,
                recipientIDs: recipientIDs,
                attachmentIDs: attachmentIDs,
                conversationID: conversation.id,
                bulkMessage: true
            )
        )
        .receive(on: scheduler)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in
                self.isSending = false
                self.reply = ""
                self.composeMessageInteractor?.cancel()
                self.dismissKeyboard?()
            }
        )
        .store(in: &self.subscriptions)
    }

    // MARK: - Private Methods
    private func listenForAnnouncements() {
        announcementsInteractor?.messages.sink { [weak self] messages in
            let announcements = messages ?? []
            self?.headerTitle = announcements.first(where: { $0.id == self?.announcementID })?.title ?? String(localized: "Announcement", bundle: .horizon)
            self?.messages = announcements
                .filter { $0.id == self?.announcementID }
                .map { announcement in
                    .init(announcement: announcement)
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
                self.messages = conversationMessages
                // Pause for the UI to update then execute a function
                self.scheduler.schedule(after: self.scheduler.now.advanced(by: .milliseconds(100))) {
                    self.isAnimationEnabled = true
                }
            }
            .store(in: &subscriptions)
    }

    private func listenForSubject() {
        announcementsInteractor?.messages.sink { [weak self] messages in
            let announcements = messages ?? []
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
                receiveValue: { [weak self] _ in
                    self?.isMarkedAsRead = true
                }
            )
            .store(in: &self.subscriptions)
        }

        return conversationMessages
    }

    private func sortOldestToNewest(_ conversationMessages: [ConversationMessage]) -> [ConversationMessage] {
        conversationMessages.sorted { $0.createdAt ?? .distantPast < $1.createdAt ?? .distantPast }
    }

    private func toViewModels(_ conversationMessages: [ConversationMessage]) -> [HMessageViewModel] {
        guard let composeMessageInteractor = composeMessageInteractor,
              let downloadFileInteractor = downloadFileInteractor,
              let userMap = messageDetailsInteractor?.userMap else {
            return []
        }
        return conversationMessages.map {
            HMessageViewModel(
                conversationMessage: $0,
                composeMessageInteractor: composeMessageInteractor,
                downloadFileInteractor: downloadFileInteractor,
                router: router,
                myID: myID,
                userMap: userMap
            )
        }
    }
}

struct HMessageViewModel: Identifiable, Hashable, Equatable {
    let attachments: [AttachmentItemViewModel]
    let author: String
    let body: String
    let date: String
    let id: String
}

extension HMessageViewModel {
    init(announcement: Announcement) {
        self.id = announcement.id
        self.body = announcement.title
        self.author = announcement.author
        self.date = announcement.date?.dateTimeString ?? ""
        self.attachments = []
    }
}

extension HMessageViewModel {
    init(
        conversationMessage: ConversationMessage,
        composeMessageInteractor: ComposeMessageInteractor,
        downloadFileInteractor: DownloadFileInteractor,
        router: Router,
        myID: String,
        userMap: [String: ConversationParticipant]
    ) {
        self.id = conversationMessage.id
        self.body = conversationMessage.body

        self.author = conversationMessage.authorID == myID ?
            String(localized: "You", bundle: .horizon) :
            (userMap[conversationMessage.authorID]?.name ?? conversationMessage.authorID)

        self.date = conversationMessage.createdAt?.dateTimeString ?? ""
        self.attachments = conversationMessage.attachments.map {
            AttachmentItemViewModel(
                $0,
                isOnlyForDownload: true,
                router: router,
                composeMessageInteractor: composeMessageInteractor,
                downloadFileInteractor: downloadFileInteractor
            )
        }
    }
}
