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
import CombineSchedulers
import Core
import Foundation

@Observable
final class AssistChatViewModel {
    // MARK: - Inputs

    var message = ""

    // MARK: - Outputs

    private(set) var chipOptions: [String]?
    private(set) var messages: [AssistChatMessageViewModel] = []
    private(set) var isBackButtonVisible: Bool = false
    private(set) var shouldOpenKeyboardPublisher = PassthroughSubject<Bool, Never>()
    private(set) var showMoreButtonPublisher = PassthroughSubject<String, Never>()
    private(set) var isLoaderVisible = false
    private(set) var isRetryButtonVisible = false
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private(set) var state: InstUI.ScreenState = .data
    var isDisableSendButton: Bool {
        message.trimmed().isEmpty || !canSendMessage
    }

    // MARK: - Inputs/Outputs

    var isErrorToastPresented = false

    // MARK: - Dependencies

    private var assistChatInteractor: AssistChatInteractor
    private let router: Router

    // MARK: - Private

    private var chatMessages: [AssistChatMessage] = []
    private var dispatchWorkItem: DispatchWorkItem?
    private var canSendMessage: Bool = true
    private var subscriptions = Set<AnyCancellable>()
    private let courseId: String?
    private let pageUrl: String?
    private let fileId: String?
    private weak var viewController: WeakViewController?
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
        self.assistChatInteractor = chatBotInteractor

        self.assistChatInteractor
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

        self.assistChatInteractor.publish(action: .begin)
    }

    // MARK: - Inputs

    func setInitialState() {
        isRetryButtonVisible = false
        isBackButtonVisible = false
        assistChatInteractor.setInitialState()
    }

    func retry() {
        guard let lastMessage = messages.popLast() else { return }
        chatMessages = chatMessages.dropLast()
        assistChatInteractor.publish(action: .chat(prompt: lastMessage.content, history: chatMessages))
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
        shouldOpenKeyboardPublisher.send(true)
        send(message: message.trimmedEmptyLines)
    }

    func send(chipOption: AssistChipOption) {
        assistChatInteractor.publish(action: .chip(option: chipOption, history: chatMessages))
        isBackButtonVisible = true
    }

    func send(message: String) {
        assistChatInteractor.publish(action: .chat(prompt: message, history: chatMessages))
        if hasAssistChipOptions {
            isBackButtonVisible = true
        }
        self.message = ""
    }

    func scrollToBottom() {
        showMoreButtonPublisher.send(messages.last?.id ?? "")
    }

    // MARK: - Private

    /// handle the response from the interactor
    private func onMessage(_ response: AssistChatResponse, viewController: WeakViewController?) {
        guard let viewController else { return }
        weak var weakSelf = self
        self.chatMessages = response.chatHistory
        var newMessages: [AssistChatMessageViewModel] = []

        shouldOpenKeyboardPublisher.send(messages.count == 1)
        newMessages = response.chatHistory.map { message in
            let onFeedbackChange: ((Bool?) -> Void)? = message.isSolicitingFeedback(with: response) ? { isGood in
                weakSelf?.onFeedbackChange(isGood)
            } : nil

            return message.viewModel(
                response: response,
                onFeedbackChange: onFeedbackChange
            ) { quickResponse in
                weakSelf?.send(chipOption: quickResponse)
            }
        }

        add(newMessages: newMessages)
        remove(notAppearingIn: newMessages)
        canSendMessage = !response.isLoading

        if response.isLoading {
            messages.append(.init(isLoading: true))
        }

        let params = ["courseId": courseId, "pageUrl": pageUrl, "fileId": fileId].map { (key, value) in
            guard let value = value else { return nil }
            return "\(key)=\(value)"
        }.compactMap { $0 }.joined(separator: "&")

        if let flashCards = response.chatHistory.last?.flashCards?.flashCardModels, flashCards.count > 0 {
            router.route(
                to: "/assistant/flashcards?\(params)",
                userInfo: ["flashCards": flashCards],
                from: viewController
            )
        } else if let quizItems = response.chatHistory.last?.quizItems {
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
        weak var weakSelf = self
        newMessages
            .filter { newMessage in
                guard let self = weakSelf else { return false }
                return !self.messages.contains { message in
                    message.id == newMessage.id
                }
            }.forEach { message in
                weakSelf?.messages.append(message)
            }
        showMoreButtonPublisher.send(newMessages.last?.id ?? "")
    }

    private func onFeedbackChange(_ isGood: Bool?) {
        guard let isGood = isGood else { return }
        let responseType = isGood ? "good" : "bad"
        Analytics.shared.logEvent("learning-assist-chat\(responseType)-response")
    }

    /// remove any messages that are not in the new list of messages returned from the interactor
    private func remove(notAppearingIn newMessages: [AssistChatMessageViewModel]) {
        messages.removeAll { message in
            !newMessages.contains { newMessage in
                message.id == newMessage.id
            } || message.isLoading
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
    func isFinalMessage(in history: [AssistChatMessage]) -> Bool {
        guard let lastMessage = history.last else { return false }
        return self.id == lastMessage.id && self.role == .Assistant
    }

    func isSolicitingFeedback(with response: AssistChatResponse) -> Bool {
        return self.role == .Assistant && self.isFinalMessage(in: response.chatHistory) && !response.isLoading
    }

    func viewModel(
        response: AssistChatResponse,
        onFeedbackChange: AssistChatMessageViewModel.OnFeedbackChange? = nil,
        onTapChipOption: AssistChatMessageViewModel.OnTapChipOption? = nil
    ) -> AssistChatMessageViewModel {
        let chipOptions = self.id == response.chatHistory.last?.id ? (response.chatHistory.last?.chipOptions ?? []) : []
        return .init(
            id: "\(self.id)\(chipOptions.count)\(onFeedbackChange != nil ? "feedback" : ""))",
            content: self.text ?? "",
            style: self.role == .Assistant ? .transparent : .white,
            chipOptions: chipOptions,
            onFeedbackChange: onFeedbackChange,
            onTapChipOption: onTapChipOption
        )
    }
}
