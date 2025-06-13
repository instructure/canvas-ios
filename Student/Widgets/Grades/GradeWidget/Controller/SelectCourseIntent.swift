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

import AppIntents
import Core
import Combine

struct CourseAppEntity: AppEntity, Identifiable {
    static var defaultQuery: CourseQuery = {
        CourseQuery()
    }()

    typealias DefaultQuery = CourseQuery

    let id: String
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Course"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: name)
    }

    init(_ course: Course) {
        self.id = course.id
        self.name = course.name ?? ""
    }
}

struct CourseQuery: EntityQuery {
    func entities(for identifiers: [CourseAppEntity.ID]) async -> [CourseAppEntity] {
        // To do
    }
}

struct ViewCourseGradesIntent: AppIntent {
    static var title: LocalizedStringResource = "Select a Course"
    static var description: LocalizedStringResource = "Configures the course for the Grade Widget."

    @Parameter(title: "Course")
    var selectedCourse: CourseAppEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Show grade for \(\.$selectedCourse)")
    }

    static var openAppWhenRun: Bool = false // Explicitly set to false

    init() {
        self.selectedCourse = nil
    }

    init(selectedCourse: CourseAppEntity?) {
        self.selectedCourse = selectedCourse
    }

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
