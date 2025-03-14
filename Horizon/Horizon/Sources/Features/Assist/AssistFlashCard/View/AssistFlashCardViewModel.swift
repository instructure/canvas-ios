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

@Observable
final class AssistFlashCardViewModel {
    // MARK: - Output

    private(set) var state: InstUI.ScreenState = .data
    private(set) var isNextButtonDisabled = false
    private(set) var isPreviousButtonDisabled = true
    private(set) var flashCards: [AssistFlashCardModel] = []
    var currentCardIndex: Int? = 0 {
        didSet {
            isPreviousButtonDisabled = currentCardIndex == 0
            isNextButtonDisabled = currentCardIndex == (flashCards.count - 1)
        }
    }

    // MARK: - Dependencies

    private let router: Router

    // MARK: - Init
    init(
        flashCards: [AssistFlashCardModel] = [],
        router: Router = AppEnvironment.shared.router
    ) {
        self.flashCards = flashCards
        self.router = router
    }

    // MARK: - Input Actions

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
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
}
