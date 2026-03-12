//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Combine
import CombineSchedulers
import Observation

@Observable
final class LearningLibraryRecommendationListViewModel {
    // MARK: - Outputs

    private(set) var recommendedItems: [LearningLibraryCardModel] = []
    var shouldShowButtons: Bool {
        recommendedItems.count > 1
    }
    var scrollPosition: String?

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: LearningLibraryInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: LearningLibraryInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.scheduler = scheduler
        loadItems()
    }

    func loadItems(ignoreCache: Bool = true) {
        interactor.getRecommendations(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .replaceError(with: [])
            .sink { [weak self] items in
                self?.recommendedItems = items
            }
            .store(in: &subscriptions)
    }

    var currentIndex: Int {
        guard let scrollPosition,
              let index = recommendedItems.firstIndex(where: { $0.id == scrollPosition }) else {
            return 0
        }
        return index
    }

    var isAtStart: Bool {
        currentIndex == 0
    }

    var isAtEnd: Bool {
        currentIndex == recommendedItems.count - 1
    }

    func goToPreviousCard() {
        let newIndex = max(0, currentIndex - 1)
        scrollPosition = recommendedItems[newIndex].id
    }

    func goToNextCard() {
        let newIndex = min(recommendedItems.count - 1, currentIndex + 1)
        scrollPosition = recommendedItems[newIndex].id
    }
}
