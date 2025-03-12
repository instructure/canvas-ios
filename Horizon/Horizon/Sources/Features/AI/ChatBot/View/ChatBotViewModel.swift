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

import Combine
import Core
import SwiftUI

@Observable
final class ChatBotViewModel {
    // MARK: - Input

    var message = ""

    // MARK: - Output

    private(set) var chipOptions: [String]?
    private(set) var state: InstUI.ScreenState = .data
    private(set) var messages: [ChatBotMessageModel] = []
    private(set) var chips: [String] = []

    var isDisableSendButton: Bool {
        message.trimmed().isEmpty
    }

    // MARK: - Dependencies

    private var chatBotInteractor: ChatBotInteractor
    private let router: Router

    // MARK: - Private

    private var chatMessages: [ChatMessage] = []
    private var dispatchWorkItem: DispatchWorkItem?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(chatBotInteractor: ChatBotInteractor, router: Router) {
        self.router = router
        self.chatBotInteractor = chatBotInteractor

        chatBotInteractor.listen.sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                    // TODO: improve displaying errors
                case .finished:
                    break
                case .failure:
                    messages = messages.dropLast()
                }
            },
            receiveValue: { [weak self] response in
                guard let self = self else { return }

                // How the chips are displayed will depend on the history
                // If we have no history, they are displayed as semitransparent message bubbles
                // If we do have a history, they are pills at the end of the last message

                self.chatMessages = response.chatHistory

                var newMessages: [ChatBotMessageModel] = []
                if response.chatHistory.isEmpty {
                    let chipOptions = response.chipOptions ?? []
                    newMessages = chipOptions.map { chipOption in
                        ChatBotMessageModel(
                            content: chipOption.chip,
                            style: .semitransparent,
                            onTap: { [weak self] in
                                self?.send(chipOption: chipOption)
                            }
                        )
                    }
                } else {
                    newMessages = response.chatHistory.map { chatMessage in
                        ChatBotMessageModel(
                            id: chatMessage.id,
                            content: chatMessage.text,
                            style: chatMessage.isBot ? .transparent : .white,
                            chipOptions: chatMessage == response.chatHistory.last ? (response.chipOptions ?? []) : [],
                            onTapChipOption: { [weak self] quickResponse in
                                self?.send(chipOption: quickResponse)
                            }
                        )
                    }
                }

                if response.isLoading {
                    dispatchWorkItem?.cancel()
                    dispatchWorkItem = DispatchWorkItem { [weak self] in
                        newMessages.append(ChatBotMessageModel())
                        withAnimation {
                            self?.messages = newMessages
                        }
                    }

                    if let dispatchWorkItem = dispatchWorkItem {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: dispatchWorkItem)
                    }
                }

                let messages = self.messages
                let addedMessages = newMessages.filter { newMessage in
                    !messages.contains { message in
                        message.id == newMessage.id
                    }
                }

                withAnimation { [weak self] in
                    self?.messages.removeAll { $0.isLoading }
                    addedMessages.forEach { message in
                        self?.messages.append(message)
                    }
                }
            }
        )
        .store(in: &subscriptions)

        chatBotInteractor.publish(action: .chat())
    }

    // MARK: - Inputs

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func send() {
        send(message: message)
    }

    func send(chipOption: ChipOption) {
        chatBotInteractor.publish(action: .chip(option: chipOption, history: chatMessages))
    }

    func send(message: String) {
        chatBotInteractor.publish(action: .chat(prompt: message, history: chatMessages))
        self.message = ""
    }
}
