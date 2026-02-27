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
import Observation
import Foundation

@Observable
final class LearnCourseListViewModel {
    // MARK: - Init / Outputs

    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let selectedStatusSubject = CurrentValueSubject<OptionModel, Never>(ProgressStatus.firstCourseOption)

    var selectedStatus: OptionModel = ProgressStatus.firstCourseOption {
        didSet {
            selectedStatusSubject.send(selectedStatus)
        }
    }
    var searchText: String = "" {
        didSet {
            searchTextSubject.send(searchText)
        }
    }

    // MARK: - Outputs

    private(set) var hasCourses = false
    private(set) var isLoaderVisiable: Bool = true
    var filteredCourses: [CourseListWidgetModel] { paginator.visibleItems }
    var isSeeMoreVisible: Bool { paginator.isSeeMoreVisible }

    // MARK: - Private variables

    private let paginator = PaginatedDataSource<CourseListWidgetModel>(items: [])
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: GetCoursesInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        interactor: GetCoursesInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
        observeSearchText()
    }

    func getCourses(ignoreCache: Bool = false, completion: (() -> Void)? = nil) {
        interactor.getCoursesWithoutModules(ignoreCache: ignoreCache)
            .map { courses in
                courses.sorted {
                    let completed1 = $0.currentLearningObject == nil
                    let completed2 = $1.currentLearningObject == nil

                    if completed1 != completed2 {
                        return !completed1
                    }
                    return $0.progress > $1.progress
                }
            }
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { CourseListWidgetModel(from: $0) }
            .collect()
            .receive(on: scheduler)
            .sink { [weak self] courses in
                guard let self else { return }
                self.paginator.setItems(courses)
                self.isLoaderVisiable = false
                self.hasCourses = courses.isNotEmpty
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
            getCourses(ignoreCache: true) { continuation.resume() }
        }
    }

    func seeMore() {
        paginator.seeMore()
    }

    private func observeSearchText() {
        Publishers.CombineLatest(
            searchTextSubject
                .debounce(for: .milliseconds(200), scheduler: scheduler)
                .removeDuplicates(),
            selectedStatusSubject
        )
        .sink { [weak self] searchText, status in
            guard let self else { return }
            self.paginator.applyFilters(query: searchText, status: status)
        }
        .store(in: &subscriptions)
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
}
