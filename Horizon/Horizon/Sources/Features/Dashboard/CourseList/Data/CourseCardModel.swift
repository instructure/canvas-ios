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

struct CourseCardModel: Identifiable, Equatable {
    let id: String
    let enrollmentID: String
    let name: String
    let progress: Double
    let programs: [CourseListWidgetModel.ProgramInfo]
    let hasPrograms: Bool
    let status: CourseStatus
    let firstProgramID: String?
    var progressPercentage: String {
        let percentage = Int(progress.rounded())
        return String(format: "%d%%", percentage)
    }

    init(course: HCourse) {
        self.id = course.id
        self.enrollmentID = course.enrollmentID
        self.name = course.name
        self.progress = course.progress
        self.programs = course.programs.map { .init(id: $0.id, name: $0.name) }
        self.hasPrograms = course.programs.isNotEmpty
        self.status = .init(progress: progress)
        self.firstProgramID = course.programs.first?.id
    }

    enum CourseStatus: CaseIterable {
        case all
        case notStarted
        case inProgress
        case completed

        init(progress: Double) {
            switch progress {
            case 100.0:
                self = .completed
            case 0.0:
                self = .notStarted
            default:
                self = .inProgress
            }
        }

        var name: String {
            switch self {
            case .all: String(localized: "All courses", bundle: .horizon)
            case .inProgress: String(localized: "In Progress", bundle: .horizon)
            case .completed: String(localized: "Completed", bundle: .horizon)
            case .notStarted: String(localized: "Not Started", bundle: .horizon)
            }
        }
    }
}
