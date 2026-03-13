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

import Core
import Combine
import CombineSchedulers
import Foundation
import Observation

@Observable
final class LearningLibraryViewModel: LearningLibraryItemNavigating {
    // MARK: - Init / Outputs

    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let selectedLearningObjectSubject = CurrentValueSubject<OptionModel, Never>(LearningLibraryObjectType.firstOption)
    private let selectedLearningLibrarySubject = CurrentValueSubject<OptionModel, Never>(LearningLibraryFilter.firstOption)

    var searchText: String = "" {
        didSet {
            searchTextSubject.send(searchText)
        }
    }
    var selectedLearningObject = LearningLibraryObjectType.firstOption {
        didSet {
            selectedLearningObjectSubject.send(selectedLearningObject)
        }
    }
    var selectedLearningLibrary = LearningLibraryFilter.firstOption {
        didSet {
            selectedLearningLibrarySubject.send(selectedLearningLibrary)
        }
    }

    // MARK: - Inputs / Outputs

    var isErrorVisible: Bool = false

    // MARK: - Outputs
    private(set) var errorMessage = ""
    private(set) var isLoaderVisible: Bool = true
    private(set) var globalSearchItems: [LearningLibraryCardModel] = []

    private(set) var isGlobalSearchActive: Bool = false
    private(set) var isGlobalSearchLoading: Bool = false
    var filteredSections: [LearningLibrarySectionModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }

    var accessibilityMessagePublisher: AnyPublisher<String, Never> {
        Publishers.Merge(
            bookmarkManager.accessibilityPublisher,
            internalAccessibilityPublisher
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Private variables

    private var internalAccessibilityPublisher = PassthroughSubject<String, Never>()
    private var reloadCollections = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var globalSearchCancellable: AnyCancellable?
    private let paginator = PaginatedDataSource<LearningLibrarySectionModel>(items: [], pageSize: 3)

    // MARK: - Dependencies

    let router: Router
    private let interactor: LearningLibraryInteractor
    private let bookmarkManager: BookmarkManager
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        router: Router,
        interactor: LearningLibraryInteractor = LearningLibraryInteractorLive(),
        bookmarkManager: BookmarkManager = BookmarkManager(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.interactor = interactor
        self.bookmarkManager = bookmarkManager
        self.scheduler = scheduler
        observeSearchAndFilters()
        reloadCollections
            .sink { [weak self] in
                guard let self else { return }
                fetchCollections()
                if isGlobalSearchActive {
                    performGlobalSearch()
                }

            }
        .store(in: &subscriptions)

        NotificationCenter.default.addObserver(
            forName: .forceRefreshJourneyCourses,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            fetchCollections(ignoreCache: true)

            if isGlobalSearchActive {
                performGlobalSearch(
                    searchText: searchText,
                    learningObject: selectedLearningObjectSubject.value,
                    learningLibrary: selectedLearningLibrarySubject.value
                )
            }
        }
    }

    deinit {
        globalSearchCancellable?.cancel()
        globalSearchCancellable = nil
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Input Actions

    func fetchCollections(ignoreCache: Bool = false, completion: (() -> Void)? = nil) {
        interactor.getLearnLibraryCollections(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.isLoaderVisible = false
                self?.showError(with: error.localizedDescription)
                completion?()
            } receiveValue: { [weak self] collections in
                guard let self else { return }
                isLoaderVisible = false
                if paginator.currentPage == 0 {
                    paginator.setItems(collections)
                } else {
                    /// Need to save the `currentPage` index when reload data after adding bookmark or enrolling
                    paginator.visibleItems = collections
                }
                completion?()
            } .store(in: &subscriptions)
    }

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            fetchCollections(ignoreCache: true) { continuation.resume() }
        }
    }

    func addBookmark(model: LearningLibraryCardModel) {
        bookmarkManager.toggleBookmark(model, using: interactor, scheduler: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.showError(with: error.localizedDescription)
            } receiveValue: { [weak self] updatedItem in
                self?.update(with: updatedItem)
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

    func seeMore() {
        paginator.seeMore()
    }

    func clearAll() {
        searchText = ""
        selectedLearningObject = LearningLibraryObjectType.firstOption
        selectedLearningLibrary = LearningLibraryFilter.firstOption
    }

    // MARK: - Navigations

    func navigateToDetails(
        section: LearningLibrarySectionModel,
        viewController: WeakViewController
    ) {
        router.show(
            LearningLibraryAssembly.makeViewController(
                pageType: .details(
                    id: section.id,
                    name: section.name
                ),
                didSendEvent: reloadCollections
            ),
            from: viewController
        )
    }

    func navigateToBookmarks(viewController: WeakViewController) {
        router.show(
            LearningLibraryAssembly.makeViewController(
                pageType: .bookmarks,
                didSendEvent: reloadCollections
            ),
            from: viewController
        )
    }

    // MARK: - Private Functions

    private func update(with collection: LearningLibraryCardModel) {
        fetchCollections()
        guard isGlobalSearchActive else { return }
        if let index = globalSearchItems.firstIndex(where: { $0.id == collection.id }) {
            globalSearchItems[index].update(with: collection)
        }
    }

    private func showError(with message: String) {
        errorMessage = message
        isErrorVisible = true
    }

    private func observeSearchAndFilters() {
        Publishers.CombineLatest3(
            searchTextSubject
                .debounce(for: .milliseconds(500), scheduler: scheduler)
                .removeDuplicates(),
            selectedLearningObjectSubject
                .removeDuplicates(),
            selectedLearningLibrarySubject
                .removeDuplicates()
        )
        .sink { [weak self] searchText, learningObject, learningLibrary in
            guard let self else { return }
            let hasSearchText = searchText.trimmedEmptyLines.isNotEmpty
            let hasObjectFilter = learningObject.id != LearningLibraryObjectType.firstOption.id
            let hasLibraryFilter = learningLibrary.id != LearningLibraryFilter.firstOption.id

            self.isGlobalSearchActive = hasSearchText || hasObjectFilter || hasLibraryFilter

            if self.isGlobalSearchActive {
                self.globalSearchCancellable?.cancel()
                self.performGlobalSearch()
            } else {
                self.globalSearchCancellable?.cancel()
                self.isGlobalSearchLoading = false
            }
        }
        .store(in: &subscriptions)
    }

    private func performGlobalSearch() {
        isGlobalSearchLoading = true

        let objectType = selectedLearningObjectSubject.value.id == LearningLibraryObjectType.firstOption.id
            ? nil
            : LearningLibraryObjectType(rawValue: selectedLearningObjectSubject.value.id)

        let libraryFilter = LearningLibraryFilter(rawValue: selectedLearningLibrarySubject.value.id) ?? .all

        globalSearchCancellable = interactor.searchWithFilters(
            searchText: searchTextSubject.value,
            objectType: objectType,
            libraryFilter: libraryFilter
        )
        .receive(on: scheduler)
        .sinkFailureOrValue { [weak self] error in
            self?.isGlobalSearchLoading = false
            self?.showError(with: error.localizedDescription)
        } receiveValue: { [weak self] collections in
            guard let self else { return }
            self.isGlobalSearchLoading = false
            self.globalSearchItems = collections
            self.announceSearchResults()
        }
    }

    private func announceSearchResults() {
        let count = globalSearchItems.count
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
