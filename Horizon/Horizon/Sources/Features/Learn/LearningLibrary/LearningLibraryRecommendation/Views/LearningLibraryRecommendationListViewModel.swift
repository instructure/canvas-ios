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
import Core

@Observable
final class LearningLibraryRecommendationListViewModel: LearningLibraryItemNavigating {
    // MARK: - Outputs

    private(set) var recommendedItems: [LearningLibraryCardModel] = []
    var shouldShowButtons: Bool {
        recommendedItems.count > 1
    }
    var scrollPosition: String?
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

    var accessibilityMessagePublisher: AnyPublisher<String, Never> {
        Publishers.Merge(
            bookmarkManager.accessibilityPublisher,
            internalAccessibilityPublisher
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Private variables

    private var internalAccessibilityPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    let router: Router
    private let didSendEvent: PassthroughSubject<Void, Never>
    private let interactor: LearningLibraryInteractor
    private let bookmarkManager: BookmarkManager
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: LearningLibraryInteractor,
        router: Router,
        didSendEvent: PassthroughSubject<Void, Never>,
        bookmarkManager: BookmarkManager = BookmarkManager(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.didSendEvent = didSendEvent
        self.bookmarkManager = bookmarkManager
        self.scheduler = scheduler
        loadItems()
    }

    func loadItems(ignoreCache: Bool = false, completion: (() -> Void)? = nil) {
        interactor.getRecommendations(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .replaceError(with: [])
            .sink { [weak self] items in
                self?.recommendedItems = items
                completion?()
            }
            .store(in: &subscriptions)
    }

    func addBookmark(model: LearningLibraryCardModel) {
        bookmarkManager.toggleBookmark(model, using: interactor, scheduler: scheduler)
            .sinkFailureOrValue { _ in
            } receiveValue: { [weak self] updatedItem in
                guard let self else { return }
                self.updateItem(item: updatedItem)
                self.didSendEvent.send(())
            }
            .store(in: &subscriptions)
    }

    func isBookmarkLoading(forItemWithId id: String) -> Bool {
        bookmarkManager.isLoading(itemId: id)
    }

    func showEnrollConfirmation(
        model: LearningLibraryCardModel,
        viewController: WeakViewController
    ) {
        let enrollViewController = EnrollConfirmationAssembly.makeView(model: model) { [weak self] item in
            self?.updateItem(item: item)
            self?.didSendEvent.send(())
            self?.navigateToLearningLibraryItem(item, from: viewController)
            self?.internalAccessibilityPublisher.send(String(localized: "Enrolled successfully"))
        }
        router.show(enrollViewController, from: viewController, options: .modal(.fullScreen))
    }

    func navigateToLearningLibraryItemDetails(
        _ model: LearningLibraryCardModel,
        from viewController: WeakViewController
    ) {
        if model.itemType == .course && !model.isEnrolled {
            showEnrollConfirmation(model: model, viewController: viewController)
        } else {
            navigateToLearningLibraryItem(model, from: viewController)
        }
    }

    private func updateItem(item: LearningLibraryCardModel) {
        if let index = recommendedItems.firstIndex(where: { $0.id == item.id }) {
            recommendedItems[index].update(with: item)
        }
    }

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            loadItems(ignoreCache: true) { continuation.resume() }
        }
    }
}
