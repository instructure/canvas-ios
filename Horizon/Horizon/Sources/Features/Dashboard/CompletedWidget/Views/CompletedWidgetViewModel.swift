//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import CombineSchedulers
import Combine
import Observation
import Foundation

@Observable
final class CompletedWidgetViewModel {
    // MARK: - Outputs

    private(set) var state: HViewState = .data
    private(set) var totalCount = 0

    // MARK: - Private Propertites

    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: CompletedWidgetInteractor
    private let learnCoursesInteractor: GetLearnCoursesInteractor

    // MARK: - Init

    init(
        interactor: CompletedWidgetInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {

        self.interactor = interactor
        self.learnCoursesInteractor = learnCoursesInteractor
        self.scheduler = scheduler
        getCompletedModulesCount()
    }

    func getCompletedModulesCount(ignoreCache: Bool = false) {
        state = .loading

        getCompletedWidgets(ignoreCache: ignoreCache)
            .zip(
                getCourses(ignoreCache: ignoreCache).setFailureType(to: Error.self)
            )
            .map { timesForCourses, learnCourses -> [CompletedWidgetModel] in
                let courseIds = learnCourses.map(\.id)
                return timesForCourses.filter { courseIds.contains($0.courseID) }
            }
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] _ in
                self?.state = .error
            } receiveValue: { [weak self] courses in
                let totalCount = courses.reduce(0) { $0 + $1.moduleCountCompleted }
                self?.totalCount = totalCount
                self?.state = totalCount > 0 ? .data : .empty
            }
            .store(in: &subscriptions)
    }

    private func getCourses(ignoreCache: Bool = false) -> AnyPublisher<[LearnCourse], Never> {
        learnCoursesInteractor
            .getCourses(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func getCompletedWidgets(ignoreCache: Bool = false) -> AnyPublisher<[CompletedWidgetModel], Error> {
        interactor
            .getCompletedWidgets(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}
