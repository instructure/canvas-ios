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

import Core
import Combine
import Foundation

protocol ProgramInteractor {
    func getPrograms(ignoreCache: Bool) -> AnyPublisher<[Program], Never>
    func getProgramsWithCourses(ignoreCache: Bool) -> AnyPublisher<[Program], Error>
    func enrollInProgram(progressID: String) -> AnyPublisher<[Program], Error>
}

final class ProgramInteractorLive: ProgramInteractor {
    // MARK: - Dependencies

    private let programCourseInteractor: ProgramCourseInteractor
    private let programsUseCase: GetHProgramsUseCase

    // MARK: - Init

    init(
        programCourseInteractor: ProgramCourseInteractor,
        programsUseCase: GetHProgramsUseCase = GetHProgramsUseCase()
    ) {
        self.programCourseInteractor = programCourseInteractor
        self.programsUseCase = programsUseCase
    }

    func getPrograms(ignoreCache: Bool) -> AnyPublisher<[Program], Never> {
        ReactiveStore(useCase: programsUseCase)
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .map { [weak self] response in
                return response.compactMap { self?.map($0) }
            }
            .eraseToAnyPublisher()
    }

    func getProgramsWithCourses(ignoreCache: Bool) -> AnyPublisher<[Program], Error> {
        getPrograms(ignoreCache: ignoreCache)
            .flatMap { [weak self] programs in
                guard let self else {
                    return Just<[Program]>([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.programCourseInteractor.getCourses(programs: programs, ignoreCache: ignoreCache)
            }
            .eraseToAnyPublisher()
    }

    func enrollInProgram(progressID: String) -> AnyPublisher<[Program], Error> {
        unowned let unownedSeldf = self
        return ReactiveStore(useCase: EnrollProgramCourseUseCase(progressId: progressID))
            .getEntities()
            .flatMap { _ in
                unownedSeldf.getProgramsWithCourses(ignoreCache: true)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Mapping

    private func map(_ program: CDHProgram) -> Program {
        let progresses = program.progresses
        let requirements = program.requirements.sorted { $0.position.intValue < $1.position.intValue }

        let courses: [ProgramCourse] = requirements.compactMap { requirement in
            guard let progress = progresses.first(where: { $0.canvasCourseId == requirement.dependent?.canvasCourseId }) else {
                return nil
            }
            return mapCourse(progress: progress, requirement: requirement)
        }

        let dateRange = formatDateRange(start: program.startDate, end: program.endDate)

        return Program(
            id: program.id,
            name: program.name,
            variant: program.variant,
            description: program.programDescription,
            date: dateRange,
            courseCompletionCount: Int(truncating: program.courseCompletionCount ?? 0),
            courses: courses
        )
    }

    private func mapCourse(progress: CDHProgramProgress, requirement: CDHProgramRequirement) -> ProgramCourse {
        ProgramCourse(
            id: (requirement.dependent?.canvasCourseId).orEmpty,
            name: (requirement.dependent?.canvasCourseId).orEmpty,
            isSelfEnrolled: requirement.courseEnrollment == CourseEnrollmentStatus.selfEnrollment.rawValue,
            isRequired: requirement.isCompletionRequired,
            status: progress.courseEnrollmentStatus,
            progressID: progress.id,
            completionPercent: Double(progress.completionPercentage) / 100.0
        )
    }

    private func formatDateRange(start: Date?, end: Date?) -> String? {
        guard let start = start?.formatted(format: "MM/dd/YYYY"),
              let end = end?.formatted(format: "MM/dd/YYYY") else {
            return nil
        }
        return "\(start)-\(end)"
    }
}

enum CourseEnrollmentStatus: String {
    case selfEnrollment = "self-enrollment"
    case autoEnrolled = "ENROLLED"
}

enum ProgramVariant: String {
    case linear = "LINEAR"
    case nonLinear = "NON_LINEAR"
}
