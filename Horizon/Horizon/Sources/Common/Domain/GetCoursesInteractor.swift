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
}

final class GetCoursesInteractorLive: GetCoursesInteractor {
    // MARK: - Properties

    private let appEnvironment: AppEnvironment
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        appEnvironment: AppEnvironment,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.appEnvironment = appEnvironment
        self.scheduler = scheduler
    }

    // MARK: - Functions

    func getCourses() -> AnyPublisher<[HCourse], Never> {
        Publishers.Zip(fetchCourses(), fetchCourseProgression())
            .receive(on: scheduler)
            .map { courses, coursesProgression in
                courses.map { course in
                    guard let progression = coursesProgression.first(
                        where: { $0.courseID == course.id }) else {
                        return course
                    }

                    var updatedCourse = course
                    let completionPercentage = progression.completionPercentage
                    updatedCourse.percentage = completionPercentage
                    updatedCourse.progressState = HCourse.ProgressState(from: completionPercentage)
                    return updatedCourse
                }
            }
            .eraseToAnyPublisher()
    }

    private func fetchCourses() -> AnyPublisher<[HCourse], Never> {
        ReactiveStore(useCase: GetCourses())
            .getEntities()
            .replaceError(with: [])
            .flatMap {
                $0.publisher
                    .flatMap { course in
                        ReactiveStore(
                            useCase: GetModules(courseID: course.id)
                        )
                        .getEntities()
                        .replaceError(with: [])
                        .map {
                            HCourse(
                                from: course,
                                modulesEntity: $0
                            )
                        }
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }

    private func fetchCourseProgression() -> AnyPublisher<[CDCourseProgression], Never> {
        let userId = appEnvironment.currentSession?.userID ?? ""
        return ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId))
            .getEntities()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
