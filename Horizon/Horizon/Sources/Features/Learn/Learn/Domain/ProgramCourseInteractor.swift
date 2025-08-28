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
import Core
import Foundation

protocol ProgramCourseInteractor {
    func getCourses(programs: [Program], ignoreCache: Bool) -> AnyPublisher<[Program], Error>
}

final class ProgramCourseInteractorLive: ProgramCourseInteractor {
    // MARK: - Dependencies

    private let userId: String

    // MARK: - Init

    init(sessionInteractor: SessionInteractor = SessionInteractor()) {
        self.userId = sessionInteractor.getUserID() ?? ""
    }

    func getCourses(programs: [Program], ignoreCache: Bool) -> AnyPublisher<[Program], Error> {
        let parameters = programs
            .flatMap { program in
                program.courses.map { course in
                    GetHProgramCourseRequest.Parameters(
                        programID: program.id,
                        courseID: course.id
                    )
                }
            }

        return ReactiveStore(
            useCase: GetHProgramCourseUseCase(userId: userId, programs: parameters)
        )
        .getEntities(ignoreCache: ignoreCache)
        .map { [weak self] response in
            self?.map(programCourses: response, programs: programs) ?? []
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Mapping

    private func map(programCourses: [CDHProgramCourse], programs: [Program]) -> [Program] {
        programs.map { program in
            var updatedProgram = program
            let coursesForProgram = programCourses.filter { $0.programID == program.id }

            updatedProgram.courses = program.courses.compactMap { course in
                mapCourse(course, with: coursesForProgram)
            }
            return updatedProgram
        }
    }

    private func mapCourse(_ course: ProgramCourse, with programCourses: [CDHProgramCourse]) -> ProgramCourse? {
        guard let programCourse = programCourses.first(where: { $0.courseID == course.id }) else {
            return nil
        }

        var updatedCourse = course
        updatedCourse.moduleItemsestimatedTime = programCourse.moduleItems.compactMap { $0.estimatedDuration }
        updatedCourse.name = programCourse.courseName
        updatedCourse.enrollemtID = programCourse.enrollemtID
        updatedCourse.completionPercent = Double(programCourse.completionPercentage) / 100.0
        return updatedCourse
    }
}
