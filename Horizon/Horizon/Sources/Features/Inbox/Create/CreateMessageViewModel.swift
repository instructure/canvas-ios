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
    var subject: String = ""
    var isSendDisabled: Bool {
        subject.isEmpty || body.isEmpty || peopleSelectionViewModel.searchByPersonSelections.isEmpty || isSending
    }

    // MARK: - Private
    private var isSending = false
    let peopleSelectionViewModel: PeopleSelectionViewModel = .init()

    // MARK: - Properties
    private let composeMessageInteractor: ComposeMessageInteractor
    private let router: Router
    private var subscriptions: Set<AnyCancellable> = []
    private let userID: String

    init(
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        composeMessageInteractor: ComposeMessageInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.userID = userID
        self.composeMessageInteractor = composeMessageInteractor
        self.router = router
    }

    func close(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func sendMessage(viewController: WeakViewController) {
        isSending = true
        composeMessageInteractor.createConversation(
            parameters: MessageParameters(
                subject: subject,
                body: body,
                recipientIDs: peopleSelectionViewModel.recipientIDs,
                context: .user(userID),
                bulkMessage: !isIndividualMessage
            )
        )
        .sink (
            receiveCompletion: {
                [weak self] _ in
                self?.isSending = false
                self?.close(viewController: viewController)
            },
            receiveValue: { _ in }
        )
        .store(in: &subscriptions)
    }
}
