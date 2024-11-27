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
import Combine
import Core

@Observable
final class AITutorViewModel {
    // MARK: - Input

    var controller = WeakViewController()
    let didSelectTutorType = PassthroughSubject<AITutorType, Never>()

    // MARK: - Private

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(router: Router) {
        self.router = router
        bindNavigation()
    }

    func presentChatBot() {
        let vc = CoreHostingController(AIAssembly.makeChatBotView())
        router.show(vc, from: controller, options: .modal(isDismissable: false))
    }

    private func bindNavigation() {
        didSelectTutorType
            .sink { [weak self] type in
                guard let self else {
                    return
                }
                switch type {
                case .quiz:
                    break
                case .summary:
                    router.route(to: "/summary", from: controller)
                case .takeAway:
                    break
                case .tellMeMore:
                    break
                case .flashCard:
                    presentFlashCard()
                }

            }
            .store(in: &subscriptions)
    }

    private func presentFlashCard() {
        let vc = CoreHostingController(AIAssembly.makeAIFlashCardView())
        router.show(vc, from: controller, options: .modal(isDismissable: false))
    }
}
