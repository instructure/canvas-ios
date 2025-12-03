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

protocol ProgramSwitcherMapper {
    func findProgram(
        containing courseID: String,
        programID: String?,
        in programs: [Program]
    ) -> ProgramSwitcherModel?

    func mapPrograms(
        programs: [Program],
        courses: [LearnCourse]
    ) -> [ProgramSwitcherModel]

    func mapProgram(program: Program?) -> ProgramSwitcherModel?
}

extension ProgramSwitcherMapper {
    func mapPrograms(
        programs: [Program],
        courses: [LearnCourse]
    ) -> [ProgramSwitcherModel] {

        let allProgramCourses = programs.flatMap(\.courses).map(\.id)
        let result: [LearnCourse] = courses.filter { !allProgramCourses.contains($0.id) }

        var switcherModels = programs.map { program in
            ProgramSwitcherModel(
                id: program.id,
                name: program.name,
                courses: program.courses.mapToProgramSwitcher(programID: program.id, programName: program.name)
            )
        }

        let extraCourses = result.map {
            ProgramSwitcherModel.Course(
                id: $0.id,
                name: $0.name,
                isEnrolled: $0.enrollmentId.isNotEmpty
            )
        }

        switcherModels.append(.init(courses: extraCourses))
        return switcherModels
    }

    func findProgram(
        containing courseID: String,
        programID: String?,
        in programs: [Program]
    ) -> ProgramSwitcherModel? {
        guard let program = getProgram(
            programID: programID,
            courseID: courseID,
            programs: programs
        ) else {
            return nil
        }

        return ProgramSwitcherModel(
            id: program.id,
            name: program.name,
            courses: program.courses.mapToProgramSwitcher(
                programID: program.id,
                programName: program.name
            )
        )
    }

    private func getProgram(
        programID: String?,
        courseID: String,
        programs: [Program]
    ) -> Program? {
        guard let programID = programID else {
            return nil
        }
        return programs.first { $0.id == programID }
    }

    func mapProgram(program: Program?) -> ProgramSwitcherModel? {
        ProgramSwitcherModel(
            id: program?.id,
            name: program?.name,
            courses: program?.courses.mapToProgramSwitcher(
                programID: program?.id,
                programName: program?.name
            ) ?? []
        )
    }
}

struct ProgramSwitcherModel: Identifiable, Equatable {
    let id: String?
    let name: String?
    let courses: [ProgramSwitcherModel.Course]

    init(
        id: String? = nil,
        name: String? = nil,
        courses: [ProgramSwitcherModel.Course] = []
    ) {
        self.id = id
        self.name = name
        self.courses = courses
    }

    var accessibilityDescription: String {
        String(format: "Part of @% program", name ?? "")
    }
    struct Course: Identifiable, Equatable {
        let id: String
        let name: String
        let programID: String?
        let programName: String?
        let isEnrolled: Bool

        init(
            id: String,
            name: String,
            programID: String? = nil,
            programName: String? = nil,
            isEnrolled: Bool
        ) {
            self.id = id
            self.name = name
            self.programID = programID
            self.programName = programName
            self.isEnrolled = isEnrolled
        }

        var hasProgram: Bool { programID != nil }
    }
}
