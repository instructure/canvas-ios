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
        fetchCourses(courseId: id)
            .map { $0.first }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetchCourses(courseId: String? = nil) -> AnyPublisher<[HCourse], Never> {
        ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId, courseId: courseId))
            .getEntities()
            .replaceError(with: [])
            .flatMap {
                $0.publisher
                    .flatMap { (courseProgression: CDCourseProgression) in

                        print("GetCoursesInteractor: Incomplete Modules length for \(courseProgression.courseID): \(courseProgression.incompleteModules.count)")
                        courseProgression.incompleteModules.forEach { incompleteModule in
                            print("\tGetCoursesInteractor: Incomplete Module Items Count: \(incompleteModule.items.count)")
                        }

                        let courseID = courseProgression.courseID
                        let institutionName = courseProgression.institutionName
                        let name = courseProgression.course.name ?? ""
                        let overviewDescription = courseProgression.course.syllabusBody
                        let progress = courseProgression.completionPercentage
                        let incompleteModules: [HModule] = courseProgression.incompleteModules.map { .init($0) }

                        return ReactiveStore(useCase: GetModules(courseID: courseProgression.courseID))
                        .getEntities()
                        .replaceError(with: [])
                        .map {
                            HCourse(
                                id: courseID,
                                institutionName: institutionName ?? "",
                                name: name,
                                overviewDescription: overviewDescription,
                                progress: progress,
                                modules: $0.map { HModule($0) },
                                incompleteModules: incompleteModules
                            )
                        }
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
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
