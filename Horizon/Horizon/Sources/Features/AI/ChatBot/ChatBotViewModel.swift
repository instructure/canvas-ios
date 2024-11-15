//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import Core
import Observation

@Observable
final class ChatBotViewModel {
    // MARK: - Input

    var message = ""

    // MARK: - Output

    private(set) var state: InstUI.ScreenState = .data
    private(set) var messages: [ChatBotMessageModel] = [
        .init(content: "How can I help you?", isMine: false)
   ]

    var isDisableSendButton: Bool {
        message.trimmed().isEmpty
    }

    // MARK: - Dependencies

    private let router: Router

    // MARK: - Init

    init(router: Router) {
        self.router = router
    }

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func sendMessage() {
        messages.append(.init(content: message, isMine: true))
        message = ""
        let loaderMessage = ChatBotMessageModel(isMine: false, isLoading: true)
        messages.append(loaderMessage)

        // Simulate a delay, then replace loader with actual response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let index = self.messages.firstIndex(where: { $0.id == loaderMessage.id }) {
                self.messages[index] = ChatBotMessageModel(
                    content: "Here's my response.",
                    isMine: false,
                    isLoading: false
                )
            }
        }
    }
}
