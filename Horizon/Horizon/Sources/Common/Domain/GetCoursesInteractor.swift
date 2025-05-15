//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import CombineExt
import CombineSchedulers
import Core
import Foundation

protocol GetCoursesInteractor {
    func getCourseWithModules(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never>
    func getCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never>
}

final class GetCoursesInteractorLive: GetCoursesInteractor {
    // MARK: - Properties

    private let userId: String
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        userId: String = AppEnvironment.shared.currentSession?.userID ?? "",
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.userId = userId
        self.scheduler = scheduler
    }

    // MARK: - Functions

    /// Fetches a singular course from graphQL, then fetches all the modules and module items from the REST api.
    /// In addition, it keeps observing Core Data changes so whenever other parts of the app update this particular course in Core Data, the caller site will also get
    /// the updated data without the need of making a new API request.
    func getCourseWithModules(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never> {
        unowned let unownedSelf = self

        return ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId, courseId: id, horizonCourses: true))
            .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .flatMap { unownedSelf.fetchModules(dashboardCourses: $0, ignoreCache: ignoreCache) }
            .map { $0.first }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId, horizonCourses: true))
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap {
                $0.publisher
                    .map { HCourse(from: $0, modules: nil) }
                    .compactMap { $0 }
                    .collect()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetchModules(dashboardCourses: [CDCourse], ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        let publishers = dashboardCourses.map { $0.fetchModules(ignoreCache: ignoreCache) }
        return publishers.combineLatest().eraseToAnyPublisher()
    }
}

extension CDCourse {
    fileprivate func fetchModules(ignoreCache: Bool) -> AnyPublisher<HCourse, Never> {
        ReactiveStore(
            useCase: GetModules(
                courseID: courseID,
                includes: GetModulesRequest.Include.allCases
            )
        )
        .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
        .replaceError(with: [])
        .map {
            HCourse(
                from: self,
                modules: $0.map { HModule(from: $0) }
            )
        }
        .eraseToAnyPublisher()
    }
}
