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
final class AssistChatViewModel {
    // MARK: - Input

    var message = ""

    // MARK: - Output

    private(set) var chipOptions: [String]?
    private(set) var messages: [AssistChatMessageViewModel] = []
    var scrollViewProxy: ScrollViewProxy?
    private(set) var state: InstUI.ScreenState = .data
    let hasAssistChipOptions: Bool

    var isDisableSendButton: Bool {
        message.trimmed().isEmpty
    }

    // MARK: - Dependencies

    private var chatBotInteractor: AssistChatInteractor
    private let router: Router

    // MARK: - Private

    private let animationDuration = 0.35
    private var chatMessages: [AssistChatMessage] = []
    private var dispatchWorkItem: DispatchWorkItem?
    private var subscriptions = Set<AnyCancellable>()
    private let courseId: String?
    private let pageUrl: String?
    private let fileId: String?

    // MARK: - Init
    init(
        courseId: String? = nil,
        pageUrl: String? = nil,
        fileId: String? = nil,
        chatBotInteractor: AssistChatInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.courseId = courseId
        self.pageUrl = pageUrl
        self.fileId = fileId
        self.router = router
        self.chatBotInteractor = chatBotInteractor
        self.hasAssistChipOptions = chatBotInteractor.hasAssistChipOptions
    }

    // MARK: - Inputs

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func listenToChatBot(viewController: WeakViewController) {
        chatBotInteractor.listen.receive(on: DispatchQueue.main).sink(
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
                self?.onMessage(message, viewController: viewController)
            }
        )
        .store(in: &subscriptions)

        chatBotInteractor.publish(action: .chat())
    }

    func send() {
        send(message: message)
    }

    func send(chipOption: AssistChipOption) {
        chatBotInteractor.publish(action: .chip(option: chipOption, history: chatMessages))
    }

    func send(message: String) {
        chatBotInteractor.publish(action: .chat(prompt: message, history: chatMessages))
        self.message = ""
    }

    // MARK: - Private

    /// handle the response from the interactor
    private func onMessage(_ response: AssistChatResponse, viewController: WeakViewController) {
        self.chatMessages = response.chatHistory

        var newMessages: [AssistChatMessageViewModel] = []

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

        if let flashCards = response.flashCards?.flashCardModels, flashCards.count > 0 {
            router.route(
                to: "/assistant/flashcards",
                userInfo: ["flashCards": flashCards],
                from: viewController
            )
        } else if let quizItem = response.quizItem {
            let quizModel = AssistQuizModel(from: quizItem)
            let params = ["courseId": courseId, "pageUrl": pageUrl, "fileId": fileId].map { (key, value) in
                guard let value = value else { return nil }
                return "\(key)=\(value)"
            }.compactMap { $0 }.joined(separator: "&")

            router.route(
                to: "/assistant/quiz?\(params)",
                userInfo: ["quizModel": quizModel],
                from: viewController
            )
        }
    }

    /// add new messages to the list of messages
    private func add(newMessages: [AssistChatMessageViewModel]) {
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
                    unownedSelf.messages.append(AssistChatMessageViewModel())
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
    private func remove(notAppearingIn newMessages: [AssistChatMessageViewModel]) {
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

// MARK: - Extensions

private extension Array where Element == AssistChatFlashCard {
    var flashCardModels: [AssistFlashCardModel] {
        self.map(\.flashCardModel)
    }
}

private extension AssistChatFlashCard {
    var flashCardModel: AssistFlashCardModel {
        AssistFlashCardModel(
            frontContent: self.question,
            backContent: self.answer
        )
    }
}

private extension AssistChipOption {
    func viewModel(onTap: AssistChatMessageViewModel.OnTap?) -> AssistChatMessageViewModel {
        AssistChatMessageViewModel(
            content: self.chip,
            style: .semitransparent,
            onTap: onTap
        )
    }
}

private extension AssistChatMessage {
    func viewModel(response: AssistChatResponse, onTapChipOption: AssistChatMessageViewModel.OnTapChipOption? = nil) -> AssistChatMessageViewModel {
        AssistChatMessageViewModel(
            id: self.id,
            content: self.text,
            style: self.role == .Assistant ? .transparent : .white,
            chipOptions: self == response.chatHistory.last ? (response.chipOptions ?? []) : [],
            onTapChipOption: onTapChipOption
        )
    }
}
