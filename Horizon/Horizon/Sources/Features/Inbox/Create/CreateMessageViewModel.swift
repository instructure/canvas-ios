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

import Core
import Combine
import SwiftUI

@Observable
class CreateMessageViewModel {
    // MARK: - Outputs
    var body: String = ""
    var cancelButtonOpacity: Double {
        sendButtonOpacity
    }
    var attachmentButtonOpacity: Double {
        attachmentViewModel.isUploading ? 0.5 : 1.0
    }
    var attachmentItems: [AttachmentItemViewModel] {
        attachmentViewModel.items
    }
    var isBodyDisabled: Bool {
        isSending
    }
    var isCheckboxDisbled: Bool {
        isSending
    }
    var isCloseDisabled: Bool {
        isSending
    }
    var isPeopleSelectionDisabled: Bool {
        isSending
    }
    var isSubjectDisabled: Bool {
        isSending
    }
    var sendButtonOpacity: Double {
        isSending ? 0.0 : 1.0
    }
    var spinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }
    var isIndividualMessage: Bool = false
    var isSendDisabled: Bool {
        subject.isEmpty ||
            body.isEmpty ||
            peopleSelectionViewModel.searchByPersonSelections.isEmpty ||
            isSending ||
            attachmentViewModel.isUploading
    }
    var subject: String = ""

    // MARK: - Private
    private var isSending = false
    let peopleSelectionViewModel: PeopleSelectionViewModel = .init()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Dependencies
    let attachmentViewModel: AttachmentViewModel
    private let composeMessageInteractor: ComposeMessageInteractor
    private let inboxMessageInteractor: InboxMessageInteractor
    let router: Router
    private let userID: String

    // MARK: - Initializer
    init(
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        attachmentViewModel: AttachmentViewModel? = nil,
        composeMessageInteractor: ComposeMessageInteractor,
        inboxMessageInteractor: InboxMessageInteractor = InboxMessageInteractorLive(
            env: AppEnvironment.shared,
            tabBarCountUpdater: .init(),
            messageListStateUpdater: .init()
        ),
        router: Router = AppEnvironment.shared.router
    ) {
        self.userID = userID
        self.attachmentViewModel = attachmentViewModel ?? AttachmentViewModel(
            router: router,
            composeMessageInteractor: composeMessageInteractor
        )
        self.composeMessageInteractor = composeMessageInteractor
        self.inboxMessageInteractor = inboxMessageInteractor
        self.router = router
    }

    // MARK: - Inputs
    func attachFile(from viewController: WeakViewController) {
        attachmentViewModel.show(from: viewController)
    }

    func close(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func sendMessage(viewController: WeakViewController) {
        isSending = true
        Task { [weak self] in
            await self?.sendMessage()
            await self?.refreshSentMessages()
            performUIUpdate {
                self?.close(viewController: viewController)
            }
        }
    }

    // MARK: - Private Methods
    private func sendMessage() async {
        await withCheckedContinuation { continuation in
            self.composeMessageInteractor.createConversation(
                parameters: MessageParameters(
                    subject: self.subject,
                    body: self.body,
                    recipientIDs: self.peopleSelectionViewModel.recipientIDs,
                    bulkMessage: !self.isIndividualMessage
                )
            )
            .sink(
                receiveCompletion: { _ in
                    continuation.resume()
                },
                receiveValue: { _ in }
            )
            .store(in: &self.subscriptions)
        }
    }

    private func refreshSentMessages() async {
        await withCheckedContinuation { continuation in
            _ = inboxMessageInteractor.setContext(.user(userID))
            _ = self.inboxMessageInteractor.setScope(.sent)
            self.inboxMessageInteractor
                .refresh()
                .sink { _ in
                    continuation.resume()
                }
                .store(in: &self.subscriptions)
        }
    }
}
