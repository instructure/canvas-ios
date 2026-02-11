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
final class LearnProgramListViewModel {
    // MARK: - Init / Outputs

    var selectedStatus: OptionModel = ProgressStatus.firsProgramOption
    var searchText: String = "" {
        didSet {
            paginator.search(query: searchText, status: selectedStatus)
        }
    }

    // MARK: - Outputs

    private(set) var isLoaderVisiable: Bool = true
    private(set) var hasPrograms: Bool = false
    var filteredPrograms: [Program] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }

    // MARK: - Private

    private let paginator = PaginatedDataSource<Program>(items: [])
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: ProgramInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: ProgramInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
    }

    // MARK: - Action Functions

    func fetchPrograms(ignoreCache: Bool = false, completion: (() -> Void)? = nil) {
        interactor.getProgramsWithCourses(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .receive(on: scheduler)
            .sink { [weak self] programs in
                self?.paginator.setItems(programs)
                self?.isLoaderVisiable = false
                self?.hasPrograms = programs.isNotEmpty
                completion?()
            }
            .store(in: &subscriptions)
    }

    func refresh() async {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
            fetchPrograms(ignoreCache: true) { continuation.resume() }
        }
    }

    func seeMore() {
        paginator.seeMore()
    }

    func filter() {
        paginator.search(query: searchText, status: selectedStatus)
    }

    func navigateToProgramDetails(id: String, viewController: WeakViewController) {
        router.show(ProgramDetailsAssembly.makeViewController(programID: id), from: viewController)
    }
}
