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
import CombineSchedulers
import Core

protocol GetCoursesInteractor {
    func getCourses() -> AnyPublisher<[HCourse], Never>
    func getCourse(id: String) -> AnyPublisher<HCourse?, Never>
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

    func getCourses() -> AnyPublisher<[HCourse], Never> {
        fetchCourses()
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getCourse(id: String) -> AnyPublisher<HCourse?, Never> {
        fetchCourses()
            .map { $0.first { $0.id == id } }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetchCourses() -> AnyPublisher<[HCourse], Never> {
        ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId))
            .getEntities()
            .replaceError(with: [])
            .flatMap {
                $0.publisher
                    .flatMap { courseProgression in
                        ReactiveStore(useCase: GetModules(courseID: courseProgression.courseID))
                        .getEntities()
                        .replaceError(with: [])
                        .map {
                            .init(
                                from: courseProgression,
                                modules: $0
                            )
                        }
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }
}

extension HCourse {
    init(
        from courseProgression: CDCourseProgression,
        modules: [Module]
    ) {
        self.init(
            id: courseProgression.courseID,
            name: courseProgression.course.name ?? "",
            overviewDescription: courseProgression.course.syllabusBody,
            progress: courseProgression.completionPercentage,
            modules: modules.map { .init($0) },
            incompleteModules: courseProgression.incompleteModules.map { .init($0) }
        )
    }
}

extension HModule {
    init(_ entity: Module) {
        self.id = entity.id
        self.name = entity.name
        self.courseID = entity.courseID
        self.items = entity.items.map { HModuleItem(from: $0) }
        self.contentItems = items.filter { $0.type?.isContentItem == true  }
        self.moduleStatus = .init(
            items: contentItems,
            state: entity.state,
            lockMessage: entity.lockedMessage,
            countOfPrerequisite: entity.prerequisiteModuleIDs.count
        )
    }
}
