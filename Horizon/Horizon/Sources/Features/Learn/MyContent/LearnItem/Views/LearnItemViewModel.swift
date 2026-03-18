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
    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            searchTextSubject.send(searchText)
        }
    }

    // MARK: - Outputs

    private(set) var loaderIsVisible: Bool = true

    var filteredItems: [LearnItemModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }

    // MARK: - Private variables

    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()
    private var currentRequestCancellable: AnyCancellable?
    private var isLoadingInProgress = false
    private let paginator = PaginatedDataSource<LearnItemModel>(items: [], pageSize: 4)

    // MARK: - Dependencies

    private let interactor: LearnItemInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: LearnItemInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.scheduler = scheduler
        observeSearchAndFilters()
    }

    private func observeSearchAndFilters() {
        searchTextSubject
//            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: scheduler)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                getLearnItem()
            }
            .store(in: &subscriptions)
    }

    func getLearnItem() {
//        guard !isLoadingInProgress else { return }

        currentRequestCancellable?.cancel()
        isLoadingInProgress = true
        loaderIsVisible = true

        currentRequestCancellable = interactor.getItems(searchTerm: searchTextSubject.value, status: ["IN_PROGRESS", "NOT_STARTED"], sortBy: "MOST_RECENT")
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
//                self?.isLoadingInProgress = false
                self?.loaderIsVisible = false
                print(error)
            } receiveValue: { [weak self] items in
//                self?.isLoadingInProgress = false
                self?.loaderIsVisible = false
                self?.paginator.setItems(items)
            }
    }

    func seeMore() {
        paginator.seeMore()
    }
}
