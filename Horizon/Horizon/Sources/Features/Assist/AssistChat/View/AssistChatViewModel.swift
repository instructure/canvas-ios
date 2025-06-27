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
import CombineSchedulers

@Observable
final class AssistChatViewModel {
    // MARK: - Inputs

    var message = ""

    // MARK: - Outputs

    private(set) var chipOptions: [String]?
    private(set) var messages: [AssistChatMessageViewModel] = []
    private(set) var isBackButtonVisible: Bool = false
    private(set) var shouldOpenKeyboardPublisher = PassthroughSubject<Bool, Never>()
    private(set) var isLoaderVisible = false
    private(set) var isRetryButtonVisible = false
    private let scheduler: AnySchedulerOf<DispatchQueue>
    var scrollViewProxy: ScrollViewProxy?
    private(set) var state: InstUI.ScreenState = .data
    var isDisableSendButton: Bool {
        message.trimmed().isEmpty || !canSendMessage
    }

    // MARK: - Inputs/Outputs

    var isErrorToastPresented = false

    // MARK: - Dependencies

    private var chatBotInteractor: AssistChatInteractor
    private let router: Router

    // MARK: - Private

    private let animationDuration = 0.35
    private var chatMessages: [AssistChatMessage] = []
    private var dispatchWorkItem: DispatchWorkItem?
    private var canSendMessage: Bool = true
    private var subscriptions = Set<AnyCancellable>()
    private let courseId: String?
    private let pageUrl: String?
    private let fileId: String?
    private var viewController = WeakViewController()
    private var hasAssistChipOptions: Bool = false

    // MARK: - Init
    init(
        courseId: String? = nil,
        pageUrl: String? = nil,
        fileId: String? = nil,
        chatBotInteractor: AssistChatInteractor,
        router: Router = AppEnvironment.shared.router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.courseId = courseId
        self.pageUrl = pageUrl
        self.fileId = fileId
        self.router = router
        self.scheduler = scheduler
        self.chatBotInteractor = chatBotInteractor

        self.chatBotInteractor
            .listen
            .receive(on: scheduler)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let message):
                    onMessage(message, viewController: viewController)
                case .failure:
                    isRetryButtonVisible = true
                    isLoaderVisible = false
                    canSendMessage = true
                    isErrorToastPresented = true
                }
            }
            .store(in: &subscriptions)

        chatBotInteractor.publish(action: .chat())
    }

    // MARK: - Inputs

    func setInitialState() {
        chatBotInteractor.setInitialState()
        isRetryButtonVisible = false
        isBackButtonVisible = false
    }

    func retry() {
        guard let lastMessage = messages.popLast() else { return }
        chatMessages = chatMessages.dropLast()
        chatBotInteractor.publish(action: .chat(prompt: lastMessage.content, history: chatMessages))
        isRetryButtonVisible = false
        shouldOpenKeyboardPublisher.send(false)
    }

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func setViewController(_ viewController: WeakViewController) {
        self.viewController = viewController
    }

    func send() {
        isRetryButtonVisible = false
        isLoaderVisible = true
        shouldOpenKeyboardPublisher.send(true)
        send(message: message.trimmedEmptyLines)
    }

    func send(chipOption: AssistChipOption) {
        chatBotInteractor.publish(action: .chip(option: chipOption, history: chatMessages))
        isBackButtonVisible = true
    }

    func send(message: String) {
        chatBotInteractor.publish(action: .chat(prompt: message, history: chatMessages))
        if hasAssistChipOptions {
            isBackButtonVisible = true
        }
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
            hasAssistChipOptions = true
            shouldOpenKeyboardPublisher.send(false)
            newMessages = chipOptions.map { chipOption in
                chipOption.viewModel { [weak self] in
                    self?.send(chipOption: chipOption)
                }
            }
        } else {
            shouldOpenKeyboardPublisher.send(messages.isEmpty)
            newMessages = response.chatHistory.map {
                $0.viewModel(response: response) { [weak self] quickResponse in
                    self?.send(chipOption: quickResponse)
                }
            }
        }

        add(newMessages: newMessages)
        remove(notAppearingIn: newMessages)
        canSendMessage = !response.isLoading
        isLoaderVisible = response.isLoading

        let params = ["courseId": courseId, "pageUrl": pageUrl, "fileId": fileId].map { (key, value) in
            guard let value = value else { return nil }
            return "\(key)=\(value)"
        }.compactMap { $0 }.joined(separator: "&")

        if let flashCards = response.flashCards?.flashCardModels, flashCards.count > 0 {
            router.route(
                to: "/assistant/flashcards?\(params)",
                userInfo: ["flashCards": flashCards],
                from: viewController
            )
        } else if let quizItems = response.quizItems {
            let quizzes = quizItems.map { AssistQuizModel(from: $0) }
            router.route(
                to: "/assistant/quiz?\(params)",
                userInfo: ["quizzes": quizzes],
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

extension Array where Element == AssistChatFlashCard {
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
