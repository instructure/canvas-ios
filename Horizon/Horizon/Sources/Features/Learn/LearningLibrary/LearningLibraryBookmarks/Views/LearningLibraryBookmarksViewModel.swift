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
import Core
import Foundation
import Observation

@Observable
final class LearningLibraryBookmarksViewModel: LearningLibraryItemNavigating {
    // MARK: - Properties

    var searchText: String = "" {
        didSet {
            searchTextSubject.send(searchText)
        }
    }
    var selectedSortOption: CollectionItemSortOption?
    var selectedFilterTypes: [CollectionItemFilterType]?

    // MARK: - Outputs

    private(set) var hasItems = false
    private(set) var isLoaderVisible: Bool = true
    private(set) var errorMessage = ""
    var isErrorVisible: Bool = false
    var filteredItems: [LearningLibraryCardModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }
    var appliedFiltersCount: Int {
        (selectedSortOption != nil ? 1 : 0) +
        (selectedFilterTypes?.filter { $0 != .all }.count ?? 0)
    }

    var accessibilityMessagePublisher: AnyPublisher<String, Never> {
        Publishers.Merge(
            bookmarkManager.accessibilityPublisher,
            internalAccessibilityPublisher
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Private variables

    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private var internalAccessibilityPublisher = PassthroughSubject<String, Never>()
    private var allItems: [LearningLibraryCardModel] = []
    private let paginator = PaginatedDataSource<LearningLibraryCardModel>(items: [], pageSize: 6)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    let router: Router
    private let interactor: LearningLibraryInteractor
    private let bookmarkManager: BookmarkManager
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: LearningLibraryInteractor,
        router: Router,
        bookmarkManager: BookmarkManager = BookmarkManager(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.interactor = interactor
        self.bookmarkManager = bookmarkManager
        self.scheduler = scheduler
        observeSearch()

        NotificationCenter.default.addObserver(
            forName: .forceRefreshJourneyCourses,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            fetchData(ignoreCache: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Input Actions

    func fetchData(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let hasFiltersApplied = selectedSortOption != nil || selectedFilterTypes != nil

        if hasFiltersApplied {
            fetchFilteredBookmarkedItems(completion: completion)
        } else {
            interactor.getBookmarkedItems(ignoreCache: ignoreCache)
                .receive(on: scheduler)
                .sinkFailureOrValue { [weak self] error in
                    self?.isLoaderVisible = false
                    self?.showError(message: error.localizedDescription)
                    completion?()
                } receiveValue: { [weak self] items in
                    self?.isLoaderVisible = false
                    self?.configResponse(items: items)
                    completion?()
                }
                .store(in: &subscriptions)
        }
    }

    private func fetchFilteredBookmarkedItems(completion: (() -> Void)? = nil) {
        isLoaderVisible = true

        let objectTypes: [LearningLibraryObjectType]? = {
            guard let filterTypes = selectedFilterTypes else { return nil }
            let converted = filterTypes
                .filter { $0 != .all }
                .compactMap { LearningLibraryObjectType(rawValue: $0.rawValue) }
            return converted.isEmpty ? nil : converted
        }()

        let sortByKey = selectedSortOption?.key
        let searchTerm = searchText.trimmedEmptyLines.isEmpty ? nil : searchText

        interactor.searchWithFilters(
            searchText: searchTerm,
            objectsType: objectTypes,
            libraryFilter: .bookmarked,
            sortBy: sortByKey
        )
        .receive(on: scheduler)
        .sinkFailureOrValue { [weak self] error in
            self?.isLoaderVisible = false
            self?.showError(message: error.localizedDescription)
            completion?()
        } receiveValue: { [weak self] items in
            self?.isLoaderVisible = false
            self?.allItems = items
            self?.hasItems = items.isNotEmpty
            self?.paginator.setItems(items)
            self?.announceSearchResults()
            completion?()
        }
        .store(in: &subscriptions)
    }

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            fetchData(ignoreCache: true) { continuation.resume() }
        }
    }

    private func observeSearch() {
        searchTextSubject
            .debounce(for: .milliseconds(200), scheduler: scheduler)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                let hasFiltersOrSearch = selectedSortOption != nil || selectedFilterTypes != nil || searchText.trimmedEmptyLines.isNotEmpty
                if hasFiltersOrSearch {
                    fetchData(ignoreCache: true)
                }
            }
            .store(in: &subscriptions)
    }

    func seeMore() {
        paginator.seeMore()
    }

    func navigateToFilter(viewController: WeakViewController) {
        let filterView = CollectionItemFilterAssembly.makeView(
            selectedSortOption: selectedSortOption,
            selectedFilterTypes: selectedFilterTypes
        ) { [weak self] sort, filters in
            guard let self else { return }
            self.selectedSortOption = sort
            self.selectedFilterTypes = filters
            self.fetchData(ignoreCache: true)
        }
        router.show(filterView, from: viewController, options: .modal(.fullScreen))
    }

    func addBookmark(model: LearningLibraryCardModel) {
        bookmarkManager.toggleBookmark(model, using: interactor, scheduler: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.showError(message: error.localizedDescription)
            } receiveValue: { [weak self] updatedItem in
                guard let self else { return }
                self.delete(with: updatedItem)
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
            self?.update(with: item)
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

    // MARK: - Private Functions

    private func configResponse(items: [LearningLibraryCardModel]) {
        allItems = items
        hasItems = allItems.isNotEmpty
        paginator.setItems(items)
        announceSearchResults()
    }

    private func update(with item: LearningLibraryCardModel) {
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems[index].update(with: item)
        }
        if let visibleIndex = self.paginator.visibleItems.firstIndex(where: { $0.id == item.id }) {
            paginator.visibleItems[visibleIndex] = item
        }
    }

    private func delete(with item: LearningLibraryCardModel) {
        allItems.removeAll(where: { item.id == $0.id })
        paginator.visibleItems.removeAll(where: { item.id == $0.id })
        hasItems = allItems.isNotEmpty
    }

    private func showError(message: String) {
        errorMessage = message
        isErrorVisible = true
    }

    private func announceSearchResults() {
        let count = paginator.visibleItems.count
        var message = ""
        if count == 0 {
            message = String(localized: "No results found")
        } else if count == 1 {
            message = String(localized: "Found 1 result")
        } else {
            message = String(format: String(localized: "Found %d results"), count)
        }
        internalAccessibilityPublisher.send(message)
    }
}
