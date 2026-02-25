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
final class LearningLibraryDetailsViewModel: LearningLibraryItemNavigating {
    // MARK: - Init / Outputs

    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let selectedLearningObjectSubject = CurrentValueSubject<OptionModel, Never>(LearningLibraryObjectType.firstOption)
    private let selectedLearningLibrarySubject = CurrentValueSubject<OptionModel, Never>(LearningLibraryFilter.firstOption)

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
    var searchText: String = "" {
        didSet {
            searchTextSubject.send(searchText)
        }
    }

    // MARK: - Outputs

    private(set) var hasItems = false
    private(set) var isLoaderVisible: Bool = true
    private(set) var errorMessage = ""
    var enrollConfirmation = EnrollConfirmationViewModel()
    var isErrorVisible: Bool = false
    var filteredItems: [LearningLibraryCardModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }
    var isClearButtonVisible: Bool {
        searchText.trimmedEmptyLines.isNotEmpty ||
        selectedLearningObject.id != LearningLibraryObjectType.firstOption.id ||
        selectedLearningLibrary.id != LearningLibraryFilter.firstOption.id
    }

    // MARK: - Private variables

    private var bookmarkLoadingStates: [String: Bool] = [:]
    private var allItems: [LearningLibraryCardModel] = []
    private let paginator = PaginatedDataSource<LearningLibraryCardModel>(items: [], pageSize: 6)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    var model: LearningLibrarySectionModel = .init(id: "", name: "", items: [])
    let router: Router
    private let didSendEvent: PassthroughSubject<Void, Never>
    private let interactor: LearningLibraryInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    let pageType: PageType

    // MARK: - Init

    init(
        interactor: LearningLibraryInteractor,
        router: Router,
        didSendEvent: PassthroughSubject<Void, Never>,
        pageType: PageType,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.pageType = pageType
        self.router = router
        self.didSendEvent = didSendEvent
        self.interactor = interactor
        self.scheduler = scheduler
        observeFilters()
    }

    // MARK: - Input Actions

    func fetchData(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        switch pageType {
        case .details(let id, _):
            fetchCollectionItems(id: id, ignoreCache: ignoreCache, completion: completion)
        case .bookmarks:
            fetchLearningLibraryItems(ignoreCache: ignoreCache, completion: completion)
        }
    }

   private func fetchLearningLibraryItems(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
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

   private func fetchCollectionItems(
        id: String,
        ignoreCache: Bool,
        completion: (() -> Void)? = nil
    ) {
        interactor.getCollectionItems(id: id, ignoreCache: ignoreCache)
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

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            fetchData(ignoreCache: true) { continuation.resume() }
        }
    }

    private func filter(searchText: String, learningObject: OptionModel, learningLibrary: OptionModel) {
        var items = allItems
        /// -1 refers to `All Items` have been selected for `LearningLibraryObjectType`
        if learningObject.id != "-1",
           let objectType = LearningLibraryObjectType(rawValue: learningObject.id) {
            items = items.filter { $0.itemType == objectType }
        }

        if let filterType = LearningLibraryFilter(rawValue: learningLibrary.id) {
            switch filterType {
            case .all:
                break
            case .completed:
                items = items.filter { $0.isCompleted }
            case .bookmarked:
                items = items.filter { $0.isBookmarked }
            }
        }

        if searchText.trimmedEmptyLines.isNotEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        paginator.setItems(items)
    }

    private func observeFilters() {
        Publishers.CombineLatest3(
            searchTextSubject
                .debounce(for: .milliseconds(200), scheduler: scheduler)
                .removeDuplicates(),
            selectedLearningObjectSubject,
            selectedLearningLibrarySubject
        )
        .sink { [weak self] searchText, learningObject, learningLibrary in
            guard let self else { return }
            self.filter(
                searchText: searchText,
                learningObject: learningObject,
                learningLibrary: learningLibrary
            )
        }
        .store(in: &subscriptions)
    }

    func seeMore() {
        paginator.seeMore()
    }

    func clearAll() {
        searchText = ""
        selectedLearningObject = LearningLibraryObjectType.firstOption
        selectedLearningLibrary = LearningLibraryFilter.firstOption
    }

    func pop(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func addBookmark(model: LearningLibraryCardModel) {
        bookmarkLoadingStates[model.id] = true
        interactor.bookmark(id: model.id, itemID: model.itemId)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                guard let self else { return }
                bookmarkLoadingStates[model.id] = false
                showError(message: error.localizedDescription)
            } receiveValue: { [weak self] item in
                guard let self else { return }
                configItem(item: item)
                bookmarkLoadingStates[model.id] = false
                didSendEvent.send(())
            }
            .store(in: &subscriptions)
    }

    func isBookmarkLoading(forItemWithId id: String) -> Bool {
        bookmarkLoadingStates[id] ?? false
    }

   private func enroll(model: LearningLibraryCardModel, viewController: WeakViewController) {
        interactor.enroll(id: model.id, itemID: model.itemId)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                guard let self else { return }
                showError(message: error.localizedDescription)

            } receiveValue: { [weak self] item in
                guard let self else { return }
                configItem(item: item)
                handleEnrollState(item: item, viewController: viewController)
                didSendEvent.send(())
            }
            .store(in: &subscriptions)
    }

    func showEnrollConfirmation(
        model: LearningLibraryCardModel,
        viewController: WeakViewController
    ) {
        enrollConfirmation = EnrollConfirmationViewModel(isLoading: false, isPresented: true) { [weak self] in
            self?.enrollConfirmation.isLoading = true
            self?.enroll(model: model, viewController: viewController)
        }
    }

    // MARK: - Private Functions

    private func configResponse(items: [LearningLibraryCardModel]) {
        allItems = items
        hasItems = allItems.isNotEmpty
        filter(
            searchText: searchTextSubject.value,
            learningObject: selectedLearningObjectSubject.value,
            learningLibrary: selectedLearningLibrarySubject.value
        )
    }

    private func configItem(item: LearningLibraryCardModel) {
        switch pageType {
        case .details:
            update(with: item)
        case .bookmarks:
            delete(with: item)
        }
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

    private func handleEnrollState(item: LearningLibraryCardModel, viewController: WeakViewController) {
        enrollConfirmation.isPresented = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.navigateToLearningLibraryItem(item, from: viewController)
        }
    }
}

extension LearningLibraryDetailsViewModel {
    enum PageType {
        case details(id: String, name: String)
        case bookmarks
        var title: String {
            switch self {
            case .details(_, let name): name
            case .bookmarks: String(localized: "Bookmarks")
            }
        }

        var emptyStateTitle: String {
            switch self {
            case .details: ""
            case .bookmarks: String(localized: "Save courses and resources here to revisit them later.")
            }
        }
        var isBookmarked: Bool {
            switch self {
            case .details: false
            case .bookmarks: true
            }
        }
    }
}
