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
    private(set) var hasLibrary: Bool = false
    private(set) var isLoaderVisible: Bool = true
    private(set) var globalSearchItems: [LearningLibraryCardModel] = []

    private(set) var isGlobalSearchActive: Bool = false
    private(set) var isGlobalSearchLoading: Bool = false
    var filteredSections: [LearningLibrarySectionModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }

    // MARK: - Private variables

    private var bookmarkLoadingStates: [String: Bool] = [:]
    private var reloadCollections = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var globalSearchCancellable: AnyCancellable?
    private let paginator = PaginatedDataSource<LearningLibrarySectionModel>(items: [], pageSize: 3)

    // MARK: - Dependencies

    let router: Router
    private let interactor: LearningLibraryInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        router: Router,
        interactor: LearningLibraryInteractor = LearningLibraryInteractorLive(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.interactor = interactor
        self.scheduler = scheduler
        observeSearchAndFilters()
        reloadCollections
            .sink { [weak self] in
            self?.fetchCollections()
        }
        .store(in: &subscriptions)
    }

    deinit {
        globalSearchCancellable?.cancel()
        globalSearchCancellable = nil
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
                hasLibrary = collections.isNotEmpty
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
        bookmarkLoadingStates[model.id] = true
        interactor.bookmark(id: model.id, itemID: model.itemId)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                guard let self else { return }
                self.bookmarkLoadingStates[model.id] = false
                showError(with: error.localizedDescription)
            } receiveValue: { [weak self] collection in
                guard let self else { return }
                self.update(with: collection)
                self.bookmarkLoadingStates[collection.id] = false
            }
            .store(in: &subscriptions)
    }

    func isBookmarkLoading(forItemWithId id: String) -> Bool {
        bookmarkLoadingStates[id] ?? false
    }

    func showEnrollConfirmation(
        model: LearningLibraryCardModel,
        viewController: WeakViewController
    ) {
        let enrollViewController = EnrollConfirmationAssembly.makeView(model: model) { [weak self] item in
            self?.update(with: item)
            self?.navigateToLearningLibraryItem(item, from: viewController)
        }
        router.show(enrollViewController, from: viewController, options: .modal(.fullScreen))
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
                self.performGlobalSearch(
                    searchText: searchText,
                    learningObject: learningObject,
                    learningLibrary: learningLibrary
                )
            } else {
                self.globalSearchCancellable?.cancel()
                self.isGlobalSearchLoading = false
            }
        }
        .store(in: &subscriptions)
    }

    private func performGlobalSearch(
        searchText: String,
        learningObject: OptionModel,
        learningLibrary: OptionModel
    ) {
        isGlobalSearchLoading = true

        let bookmarkedOnly = learningLibrary.id == LearningLibraryFilter.bookmarked.rawValue
        let completedOnly = learningLibrary.id == LearningLibraryFilter.completed.rawValue

        let types: [String]?
        if learningObject.id == LearningLibraryObjectType.firstOption.id {
            types = nil
        } else {
            types = [learningObject.id]
        }

        globalSearchCancellable = interactor.searchCollectionItem(
            bookmarkedOnly: bookmarkedOnly,
            completedOnly: completedOnly,
            types: types,
            searchTerm: searchText.trimmedEmptyLines.isEmpty ? nil : searchText
        )
        .receive(on: scheduler)
        .sinkFailureOrValue { [weak self] error in
            self?.isGlobalSearchLoading = false
            self?.showError(with: error.localizedDescription)
        } receiveValue: { [weak self] collections in
            self?.isGlobalSearchLoading = false
            self?.globalSearchItems = collections
        }
    }
}
