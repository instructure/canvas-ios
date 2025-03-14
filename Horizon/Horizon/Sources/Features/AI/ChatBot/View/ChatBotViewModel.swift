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
    private(set) var messages: [ChatBotMessageModel] = []
    var scrollViewProxy: ScrollViewProxy?
    private(set) var state: InstUI.ScreenState = .data

    var isDisableSendButton: Bool {
        message.trimmed().isEmpty
    }

    // MARK: - Dependencies

    private var chatBotInteractor: ChatBotInteractor
    private let router: Router

    // MARK: - Private

    private let animationDuration = 0.35
    private var chatMessages: [ChatMessage] = []
    private var dispatchWorkItem: DispatchWorkItem?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init
    init(chatBotInteractor: ChatBotInteractor, router: Router = AppEnvironment.shared.router) {
        self.router = router
        self.chatBotInteractor = chatBotInteractor

        chatBotInteractor.listen.sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure:
                    messages = messages.dropLast()
                }
            },
            receiveValue: { [weak self] message in
                self?.onMessage(message)
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

    // MARK: - Private

    /// handle the response from the interactor
    private func onMessage(_ response: ChatBotResponse) {
        self.chatMessages = response.chatHistory

        var newMessages: [ChatBotMessageModel] = []

        // How the chips are displayed will depend on the history
        // If we have no history, they are displayed as semitransparent message bubbles
        // If we do have a history, they are pills at the end of the last message
        if response.chatHistory.isEmpty {
            let chipOptions = response.chipOptions ?? []
            newMessages = chipOptions.map { chipOption in
                chipOption.viewModel { [weak self] in
                    self?.send(chipOption: chipOption)
                }
            }
        } else {
            newMessages = response.chatHistory.map {
                $0.viewModel(response: response) { [weak self] quickResponse in
                    self?.send(chipOption: quickResponse)
                }
            }
        }

        add(newMessages: newMessages)
        remove(notAppearingIn: newMessages)
        addLoadingMessageAfterDelay(if: response.isLoading)
    }

    /// add new messages to the list of messages
    private func add(newMessages: [ChatBotMessageModel]) {
        withAnimation(.easeInOut(duration: animationDuration)) { [weak self] in
            guard let self = self else { return }

            newMessages.filter { newMessage in
                !self.messages.contains { message in
                    message.id == newMessage.id
                }
            }.forEach { message in
                self.messages.append(message)
            }
        }
    }

    /// add a loading message after a delay if the response is still loading
    private func addLoadingMessageAfterDelay(if isLoading: Bool) {
        unowned let unownedSelf = self
        if isLoading {
            dispatchWorkItem?.cancel()
            dispatchWorkItem = DispatchWorkItem {
                unownedSelf.withAnimationAndScrollToBottom {
                    unownedSelf.messages.append(ChatBotMessageModel())
                }
            }
            dispatchWorkItem.map { dispatchWorkItem in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: dispatchWorkItem)
            }
        }
    }

    /// animate the addition of a message and scroll to the bottom of the list after the animation completes
    private func withAnimationAndScrollToBottom(_ block: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: animationDuration)) {
            block()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            if let lastMessage = self?.messages.last {
                self?.scrollViewProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    /// remove any messages that are not in the new list of messages returned from the interactor
    private func remove(notAppearingIn newMessages: [ChatBotMessageModel]) {
        withAnimationAndScrollToBottom { [weak self] in
            guard let self = self else { return }
            self.messages.removeAll { message in
                !newMessages.contains { newMessage in
                    message.id == newMessage.id
                } || message.isLoading
            }
        }
    }
}

extension ChipOption {
    func viewModel(onTap: ChatBotMessageModel.OnTap?) -> ChatBotMessageModel {
        ChatBotMessageModel(
            content: self.chip,
            style: .semitransparent,
            onTap: onTap
        )
    }
}

extension ChatMessage {
    func viewModel(response: ChatBotResponse, onTapChipOption: ChatBotMessageModel.OnTapChipOption? = nil) -> ChatBotMessageModel {
        ChatBotMessageModel(
            id: self.id,
            content: self.text,
            style: self.role == .Assistant ? .transparent : .white,
            chipOptions: self == response.chatHistory.last ? (response.chipOptions ?? []) : [],
            onTapChipOption: onTapChipOption
        )
    }
}
