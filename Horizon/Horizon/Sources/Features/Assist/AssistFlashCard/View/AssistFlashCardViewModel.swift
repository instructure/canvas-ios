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
import Observation
import Core
import Combine
import CombineSchedulers

@Observable
final class AssistFlashCardViewModel {
    // MARK: - Output

    private(set) var isLoaderVisible = false
    private(set) var errorMessage: String?
    private(set) var isNextButtonDisabled = false
    private(set) var isPreviousButtonDisabled = true
    private(set) var flashCards: [AssistFlashCardModel] = []
    var ofText: String {
        let currentCardIndex = (currentCardIndex ?? 0) + 1
        return String(
            format: String(localized: "page_of_pages", bundle: .horizon),
            currentCardIndex,
            flashCards.count
        )
    }
    var currentCardIndex: Int? = 0 {
        didSet {
            isPreviousButtonDisabled = currentCardIndex == 0
            isNextButtonDisabled = currentCardIndex == (flashCards.count - 1)
        }
    }

    // MARK: - Private Propertites

    private var chatHistory: [AssistChatMessage] = []
    private var paginatedFlashCards: [[AssistFlashCardModel]] = [[]]
    private var currentPage = 0

    // MARK: - Dependencies

    private let router: Router
    private let chatBotInteractor: AssistChatInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init
    init(
        flashCards: [AssistFlashCardModel] = [],
        router: Router = AppEnvironment.shared.router,
        chatBotInteractor: AssistChatInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.paginatedFlashCards = flashCards.chunked(into: 5)
        self.router = router
        self.chatBotInteractor = chatBotInteractor
        self.scheduler = scheduler
        self.flashCards = paginatedFlashCards.first ?? []
        self.chatBotInteractor
            .listen
            .receive(on: scheduler)
            .sink { [weak self] result in
                switch result {
                case .success(let message):
                    self?.onMessage(message)
                case .failure(let error):
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        .store(in: &subscriptions)
    }

    // MARK: - Input Actions

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func pop(controller: WeakViewController) {
        router.pop(from: controller)
    }

    func goToNextCard() {
        currentCardIndex = (currentCardIndex ?? 0) + 1
    }

    func goToPreviousCard() {
        currentCardIndex = (currentCardIndex ?? 0) - 1
    }

    func makeCardFlipped(at index: Int) {
        guard flashCards.indices.contains(index) else { return }
        flashCards[index].makeItFlipped()
    }

    func regenerate() {
        let countFlashCards = paginatedFlashCards.count
        guard currentPage < countFlashCards - 1 else {
            isLoaderVisible = true
            currentPage = 0
            chatBotInteractor.publish(
                action: .chip(
                    option: AssistChipOption(
                        chip: String(localized: "Generate Flash Cards", bundle: .horizon),
                        prompt: "Generate Flash Cards"
                    ),
                    history: chatHistory
                )
            )
            return
        }
        currentPage += 1
        flashCards = paginatedFlashCards[safe: currentPage] ?? []
        currentCardIndex = 0
    }

    private func onMessage(_ response: AssistChatResponse) {
        chatHistory = response.chatHistory
        guard let flashCardModels =  response.chatHistory.last?.flashCards?.flashCardModels else {
            return
        }
        currentCardIndex = 0
        currentPage = 0
        paginatedFlashCards = flashCardModels.chunked(into: 5)
        flashCards = paginatedFlashCards.first ?? []
        isLoaderVisible = response.isLoading
    }
}
