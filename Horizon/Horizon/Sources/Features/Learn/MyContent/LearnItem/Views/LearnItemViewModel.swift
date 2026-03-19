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
final class LearnItemViewModel {
    // MARK: - Inputs / Outputs

    var isErrorVisible: Bool = false
    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            searchTextSubject.send(searchText)
        }
    }

    // MARK: - Outputs

    private(set) var isLoaderVisible: Bool = true
    private(set) var hasItems: Bool = false
    private(set) var errorMessage = ""

    var filteredItems: [LearnItemModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }
    var hasActiveFilters: Bool {
        !searchText.isEmpty || selectedFilterTypes?.isNotEmpty == true
    }

    // MARK: - Private variables

    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()
    private var currentRequestCancellable: AnyCancellable?
    private let paginator = PaginatedDataSource<LearnItemModel>(items: [], pageSize: 4)
    private var selectedSortOption: CollectionItemSortOption?
    private var selectedFilterTypes: [LearnItemModel.UIItemType]?

    // MARK: - Dependencies

    private let router: Router
    private let interactor: LearnItemInteractor
    private let status: [LearnItemModel.Status]
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        router: Router,
        interactor: LearnItemInteractor,
        status: [LearnItemModel.Status],
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.interactor = interactor
        self.status = status
        self.scheduler = scheduler
        observeSearchAndFilters()
    }

    private func observeSearchAndFilters() {
        searchTextSubject
            .debounce(for: .milliseconds(500), scheduler: scheduler)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                isLoaderVisible = true
                getLearnItem()
            }
            .store(in: &subscriptions)
    }

    func getLearnItem(completion: (() -> Void)? = nil) {
        currentRequestCancellable?.cancel()
        currentRequestCancellable = interactor.getItems(
            searchTerm: searchTextSubject.value,
            itemTypes: selectedFilterTypes?.map {$0.key},
            sortBy: selectedSortOption?.key,
            status: status)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.isLoaderVisible = false
                self?.errorMessage = error.localizedDescription
                self?.isErrorVisible = true
                completion?()
            } receiveValue: { [weak self] items in
                guard let self else { return }
                isLoaderVisible = false
               hasItems = hasItems ? hasItems : items.isNotEmpty
               paginator.setItems(items)
                completion?()
            }
    }

    func seeMore() {
        paginator.seeMore()
    }

    func refresh() async {
        await withCheckedContinuation { [weak self]  continuation in
            guard let self else {
                continuation.resume()
                return
            }
            getLearnItem { continuation.resume() }
        }
    }

    func showFilter(viewController: WeakViewController) {
      let filterView = LearnItemFilterAssembly.makeView(
            selectedSortOption: selectedSortOption,
            selectedFilterTypes: selectedFilterTypes) { [weak self] sort, status in
                self?.selectedSortOption = sort
                self?.selectedFilterTypes = status
                self?.isLoaderVisible = true
                self?.getLearnItem()
            }
        router.show(filterView, from: viewController, options: .modal(.fullScreen))
    }

    func navigateToProgramDetails(id: String, viewController: WeakViewController) {
        router.show(ProgramDetailsAssembly.makeViewController(programID: id), from: viewController)
    }

    func navigateToCourseDetails(
        id: String,
        enrollmentID: String,
        programName: String?,
        viewController: WeakViewController
    ) {
        router.show(
            CourseDetailsAssembly.makeCourseDetailsViewController(
                courseID: id,
                enrollmentID: enrollmentID,
                programName: programName
            ),
            from: viewController
        )
    }

    func navigateToItemSequence(
        url: URL,
        learningObject: CourseListWidgetModel.LearningObjectInfo,
        viewController: WeakViewController
    ) {
        let moduleItem = HModuleItem(
            id: learningObject.id,
            title: learningObject.name,
            htmlURL: learningObject.url,
            /// `isCompleted` is set to `false` because this is the next module item
            /// the learner must complete. If it were `true`, it would no longer appear here.
            isCompleted: false
        )
        router.route(to: url, userInfo: ["moduleItem": moduleItem], from: viewController)
    }
}
