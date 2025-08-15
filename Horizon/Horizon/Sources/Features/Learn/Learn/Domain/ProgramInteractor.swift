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

import Foundation
import Core
import Combine
import HorizonUI

protocol ProgramInteractor {
    //    func getPrograms(programs: [Program]) -> [Program]
}

final class ProgramInteractorLive: ProgramInteractor {
    private var subscriptions = Set<AnyCancellable>()

    func getPrograms() -> AnyPublisher<[Program], Error> {
        ReactiveStore(useCase: GetHProgramsUseCase())
            .getEntities(ignoreCache: true)
            .map { response in
                let programs = response.map { ProgramDTO(from: $0) }
                let sortedPrograms = self.normalizePrograms(programs: programs)
                return sortedPrograms.map { self.map(program: $0) }
            }
            .eraseToAnyPublisher()
    }

    private func normalizePrograms(programs: [ProgramDTO]) -> [ProgramDTO] {
        programs.map { program in
            var copy = program
            copy.requirements = sortRequirementsByDependency(requirements: program.requirements)
            return copy
        }
    }

    private func sortRequirementsByDependency(requirements: [ProgramRequirementDTO]) -> [ProgramRequirementDTO] {
        guard let start = requirements.first(where: { $0.dependency == nil }) else {
            return requirements
        }

        var sorted: [ProgramRequirementDTO] = [start]
        var current = start

        while let nextId = current.dependent?.id,
              let next = requirements.first(where: { $0.dependency?.id == nextId }) {
            sorted.append(next)
            current = next
        }
        return sorted
    }

    private func map(program: ProgramDTO) -> Program {
        let requirements = program.requirements
        let progresses = program.progresses
        var sortedProgresses: [ProgramProgressDTO] = []
        var courses: [ProgramCourse] = []
        requirements.forEach { requirement in
            if let progess = progresses.first(where: { $0.canvasCourseId == requirement.dependent?.canvasCourseId }) {
                sortedProgresses.append(progess)
            }
        }

        zip(requirements, sortedProgresses).forEach { requirement, progress in
            let course = mapCourse(progress: progress, requirement: requirement)
            courses.append(course)
        }
        let startDate = program.startDate?.formatted(format: "MM/dd/YYYY")
        let endDate = program.endDate?.formatted(format: "MM/dd/YYYY")
        let date = if let startDate, let endDate { "\(endDate)-\(endDate)" } else { nil }
        var program = Program(
            id: program.id,
            name: program.name,
            isLinear: program.variant == ProgramVariant.linear.rawValue,
            description: program.programDescription,
            completionPercent: 0,
            date: date,
            courseCompletionCount: program.courseCompletionCount,
            courses: courses
        )

        program.completionPercent = getProgramProgression(program: program)
        return program
    }

    private func mapCourse(
        progress: ProgramProgressDTO,
        requirement: ProgramRequirementDTO
    ) -> ProgramCourse {
        ProgramCourse(
            id: requirement.dependent?.canvasCourseId ?? "",
            name: requirement.dependent?.canvasCourseId ?? "",
            isSelfEnrolled: requirement.courseEnrollment == CourseEnrollmentStatus.selfEnrollment.rawValue,
            isRequired: requirement.isCompletionRequired,
            estimatedTime: "TODO",
            dueDate: "TODO",
            status: progress.courseEnrollmentStatus,
            completionPercent: progress.completionPercentage
        )
    }

    private func getProgramProgression(program: Program) -> Double {
        guard program.courses.isNotEmpty else {
            return 0
        }

        var coursesForProgress: [ProgramCourse] = []
        let countOfCourses = program.courses.count
        if program.isLinear {
            coursesForProgress = program.courses.filter { $0.isRequired }
        } else {
            var courseCompletionCountValue = program.courseCompletionCount ?? countOfCourses
            
            if courseCompletionCountValue > countOfCourses {
                courseCompletionCountValue = countOfCourses
            }
            coursesForProgress = Array(
                program.courses
                    .sorted { ($0.completionPercent) > ($1.completionPercent) } // Descending
                    .prefix(courseCompletionCountValue)
            )
        }

        guard coursesForProgress.isNotEmpty else {
            print(program.name ,"====isNotEmpty =====")
            return 0
        }

        let totalProgress = coursesForProgress.reduce(0) { accumulator, course in
            accumulator + (course.completionPercent)
        }

        let completionPercentage = totalProgress / (Double(countOfCourses) * 100)
        return completionPercentage
    }
}

enum CourseEnrollmentStatus: String {
    case selfEnrollment = "self-enrollmen"
    case autoEnrolled = "ENROLLED"
}

enum ProgramVariant: String {
    case linear = "LINEAR"
    case nonLinear = "NON_LINEAR"
}
