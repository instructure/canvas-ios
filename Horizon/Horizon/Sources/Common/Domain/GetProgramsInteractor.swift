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

protocol GetProgramsInteractor {
    func getPrograms() -> AnyPublisher<[HProgram], Never>
}

final class GetProgramsInteractorLive: GetProgramsInteractor {
    // MARK: - Properties
    private let appEnvironment: AppEnvironment
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init
    init(appEnvironment: AppEnvironment,
         scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.appEnvironment = appEnvironment
        self.scheduler = scheduler
    }

    // MARK: - Functions
    func getPrograms() -> AnyPublisher<[HProgram], Never> {
        Publishers.Zip(fetchPrograms(), fetchCourseProgression())
            .receive(on: scheduler)
            .map { programs, enrollmentCourses in
                programs.map { program in
                    guard let progression = enrollmentCourses.first(
                        where: { $0.course?.id == program.course.id }) else {
                        return program
                    }

                    var updatedProgram = program
                    let completionPercentage = progression.course?
                        .usersConnection?
                        .nodes?
                        .first?
                        .courseProgression?
                        .requirements?
                        .completionPercentage ?? 0

                    updatedProgram.percentage = completionPercentage
                    updatedProgram.progressState = HProgram.ProgressState(from: completionPercentage)
                    return updatedProgram
                }
            }
            .eraseToAnyPublisher()
    }

    private func fetchPrograms() -> AnyPublisher<[HProgram], Never> {
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
                            HProgram(
                                courseEntity: course,
                                modulesEntity: $0
                            )
                        }
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }

    private func fetchCourseProgression() -> AnyPublisher<[GetCoursesProgressionResponse.EnrollmentModel], Never> {
        let userId = appEnvironment.currentSession?.userID ?? ""
        let request = GetCoursesProgressionRequest(userId: userId)

        return Future<[GetCoursesProgressionResponse.EnrollmentModel], Never> { [appEnvironment] promise in
            appEnvironment.api.makeRequest(request) { response, _, _ in
                let enrollments = response?.data?.user?.enrollments ?? []
                promise(.success(enrollments))
            }
        }
        .eraseToAnyPublisher()
    }
}
