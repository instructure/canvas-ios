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
    var isSendDisabled: Bool {
        reply.isEmpty || isSending
    }
    @Published var reply: String = ""
    var sendButtonOpacity: Double {
        isSending ? 0.0 : 1.0
    }
    var loadingSpinnerOpacity: Double {
        isSending ? 1.0 : 0.0
    }

    // MARK: - Private
    private var isSending: Bool = false

    // MARK: - Dependencies
    private let composeMessageInteractor: ComposeMessageInteractor
    private let messageDetailsInteractor: MessageDetailsInteractor
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        router: Router = AppEnvironment.shared.router,
        messageDetailsInteractor: MessageDetailsInteractor,
        composeMessageInteractor: ComposeMessageInteractor,
        myID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        allowArchive: Bool
    ) {
        self.router = router
        self.messageDetailsInteractor = messageDetailsInteractor
        self.composeMessageInteractor = composeMessageInteractor
        super.init(
            router: router,
            interactor: messageDetailsInteractor,
            myID: myID,
            allowArchive: allowArchive
        )
    }

    // MARK: - Inputs
    func pop(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func refresh(finish: @escaping () -> Void) {
        _ = messageDetailsInteractor.refresh().sink {
            finish()
        }
    }

    func sendMessage(viewController: WeakViewController) {
        isSending = true
        Task { [weak self] in
            guard let self = self else {
                return
            }
            _ = self.composeMessageInteractor.addConversationMessage(
                parameters: MessageParameters(
                    subject: "",
                    body: self.reply,
                    recipientIDs: self.messageDetailsInteractor.userMap.map { $0.key },
                    attachmentIDs: [],
                    bulkMessage: false
                )
            ).sink(
                receiveCompletion: { _ in
                    performUIUpdate {
                        self.isSending = false
                        self.reply = ""
                        _ = self.messageDetailsInteractor.refresh()
                    }
                },
                receiveValue: { _ in }
            )
        }
    }
}
