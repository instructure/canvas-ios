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

import Combine
import CombineSchedulers
import Foundation
import Observation

@Observable
final class BookmarkManager {
    private(set) var loadingStates: [String: Bool] = [:]
    let accessibilityPublisher = PassthroughSubject<String, Never>()

    private var subscriptions = Set<AnyCancellable>()

    func toggleBookmark(
        _ item: LearningLibraryCardModel,
        using interactor: LearningLibraryInteractor,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnyPublisher<LearningLibraryCardModel, Error> {
        loadingStates[item.id] = true

        return interactor.bookmark(id: item.id, courseID: item.courseID)
            .receive(on: scheduler)
            .map { _ in
                var updatedItem = item
                updatedItem.isBookmarked = !updatedItem.isBookmarked
                return updatedItem
            }
            .handleEvents(
                receiveOutput: { [weak self] updatedItem in
                    guard let self else { return }
                    self.loadingStates[item.id] = false
                    let message = updatedItem.isBookmarked
                        ? String(localized: "Added to bookmarks")
                        : String(localized: "Removed from bookmarks")
                    self.accessibilityPublisher.send(message)
                },
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure = completion {
                        self.loadingStates[item.id] = false
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    func isLoading(itemId: String) -> Bool {
        loadingStates[itemId] ?? false
    }
}
