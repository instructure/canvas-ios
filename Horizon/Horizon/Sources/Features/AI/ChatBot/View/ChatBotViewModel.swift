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

    private var chatbotInteractor: ChatBotInteractor
    private let router: Router

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var chatMessages: [ChatMessage] = [] {
        didSet {
            messages = chatMessages.map {
                ChatBotMessageModel(content: $0.text, isMine: $0.isBot == false)
            }
        }
    }

    // MARK: - Init
    init(chatbotInteractor: ChatBotInteractor, router: Router) {
        self.router = router
        self.chatbotInteractor = chatbotInteractor

        chatbotInteractor.listen.sink(
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
                self.chatMessages = response.chatHistory
                self.chips = response.chipOptions ?? []
            }
        )
        .store(in: &subscriptions)

        chatbotInteractor.publish(action: .chat())
    }

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func sendMessage() {
        chatbotInteractor.publish(action: .chat(prompt: message, history: chatMessages))
        message = ""
    }
}

extension Array where Element == ChatBotMessageModel {
    var chatBotMessages: [ChatBotMessage] {
        map { $0.toChatBotMessage() }
    }
}

extension Array where Element == ChatBotMessage {
    var chatBotMessageModels: [ChatBotMessageModel] {
        map { $0.toChatBotMessageModel() }
    }
}

extension ChatBotMessageModel {
    func toChatBotMessage() -> ChatBotMessage {
        .init(text: content, role: isMine ? .user : .assistant)
    }
}

extension ChatBotMessage {
    func toChatBotMessageModel() -> ChatBotMessageModel {
        .init(content: text, isMine: role == .user)
    }
}
