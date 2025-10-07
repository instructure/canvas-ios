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

import Combine
import CombineSchedulers
import Core
import Foundation

protocol CourseCardsInteractor {
    func getAndObserveCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Error>
    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never>
}

final class CourseCardsInteractorLive: CourseCardsInteractor {
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

    /// Fetches all courses from graphQL but doesn't fetch modules from the REST api.
    /// In addition, it keeps listening for `moduleItemRequirementCompleted` notifications and makes a new request to graphQL whenever it receives one.
    func getAndObserveCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Error> {
        unowned let unownedSelf = self

        return NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .prepend(.init(name: .moduleItemRequirementCompleted))
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .flatMap { param -> AnyPublisher<[HCourse], Error> in
                let shouldIgnoreCache = param.object != nil ? true : ignoreCache
                return ReactiveStore(useCase: GetHCoursesProgressionUseCase(userId: unownedSelf.userId, horizonCourses: true))
                    .getEntities(ignoreCache: shouldIgnoreCache)
                    .flatMap {
                        $0.publisher
                            .map { HCourse(from: $0, modules: nil) }
                            .compactMap { $0 }
                            .collect()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            .map { courses in
                courses.sorted {
                    ($0.currentLearningObject != nil) && ($1.currentLearningObject == nil)
                }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .compactMap { $0.object as? ModuleItemAttributes }
            .flatMap {
                Publishers.Zip(
                    ReactiveStore(
                        useCase: GetModuleItem(
                            courseID: $0.courseID,
                            moduleID: $0.moduleID,
                            itemID: $0.itemID
                        )
                    )
                    .getEntities(ignoreCache: true),

                    ReactiveStore(
                        useCase: GetModule(
                            courseID: $0.courseID,
                            moduleID: $0.moduleID
                        )
                    )
                    .getEntities(ignoreCache: true)
                )
            }
            .replaceError(with: ([], []))
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
