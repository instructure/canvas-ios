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

struct Program: Identifiable {
    let id: String
    let name: String
    let variant: String
    let description: String?
    let date: String?
    let courseCompletionCount: Int?
    var courses: [ProgramCourse]

    var estimatedTime: String? {
        let times = courses.filter(\.isRequired).flatMap(\.moduleItemsestimatedTime)
        let formatter = ISO8601DurationFormatter()
        return times.isEmpty ? nil : formatter.sum(durations: times)
    }

    var isLinear: Bool {
        variant == ProgramVariant.linear.rawValue && !isOptionalProgram
    }

    var isOptionalProgram: Bool {
        courses.allSatisfy { !$0.isRequired }
    }

    var completionPercent: Double {
        if isLinear {
            let requiredCourses = courses.filter(\.isRequired)
            let sum = requiredCourses.reduce(0) { $0 + $1.completionPercent }
            return sum / (Double(requiredCourses.count))
        } else {
            let courseLimit = min(courseCompletionCount ?? courses.count, courses.count)
            let requiredCourses = courses.filter(\.isRequired)
            let coursesForProgress = requiredCourses
                .sorted { $0.completionPercent > $1.completionPercent }
                .prefix(courseLimit)
                .map { $0 }
            let sum = coursesForProgress.reduce(0) { $0 + $1.completionPercent }
            return courseLimit > 0 ? sum / Double(courseLimit) : 0
        }
    }

    var hasPills: Bool {
        estimatedTime != nil || date != nil
    }

    var countOfRemeaningCourses: Int {
        courses.filter { $0.isRequired && !$0.isCompleted }.count
    }

    var hasEnrolledCourse: Bool {
        courses.contains { $0.status == ProgramCourse.Status.enrolled.rawValue }
    }

    var accessibilityHeader: String {
        var description = String.localizedStringWithFormat(
            String(localized: "Selected program is %@. ", bundle: .horizon),
            name
        )

        description += String(localized: "Double tap to select another program. ", bundle: .horizon)
        return description
    }

    var accessibilityDescription: String {
        var text: String = ""
        if  isOptionalProgram == false {
            if completionPercent == 0 {
                text += String(localized: "The program hasn’t started yet. ")
            } else {
                text += String.localizedStringWithFormat(
                    String(localized: "Progress: %d percent complete. ", bundle: .horizon),
                    Int(round(completionPercent * 100))
                )
            }
        }

        if let description {
            text += String(format: String(localized: "Description %@. "), description)
        }

        if let date {
            text += String(format: String(localized: "Date %@. "), date)
        }

        if let estimatedTime {
            text += String(format: String(localized: "Estimated time %@. "), estimatedTime)
        }
        if !isLinear, !isOptionalProgram {
            text += String(
                format: String(localized: "Complete %d of %d courses. ", bundle: .horizon),
                countOfRemeaningCourses,
                courses.count
            )
        }

        let type = isLinear ? String(localized: "Linear") : String(localized: "Non Linear")
        let status = isOptionalProgram ? String(localized: "Optional") : String(localized: "Required")
        text += String(format: "%@ and %@ Program.", type, status)
        return text
    }
}

struct ProgramCourse: Identifiable, Equatable {
    let id: String
    var name: String = ""
    let isSelfEnrolled: Bool
    let isRequired: Bool
    let status: String
    let progressID: String
    var completionPercent: Double
    var moduleItemsestimatedTime: [String] = []
    var index = 0

    var estimatedTime: String? {
        let formatter = ISO8601DurationFormatter()
        return moduleItemsestimatedTime.isEmpty ? nil : formatter.sum(durations: moduleItemsestimatedTime)
    }

    var isCompleted: Bool {
        completionPercent == 1
    }

    var isEnrolled: Bool {
        courseStatus == .enrolled
    }

    var courseStatus: ProgramCourse.Status {
        Status(rawValue: status) ?? .enrolled
    }

    func ordinalString(from number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

     func accessibilityLabelText(status: ProgramCardStatus, isLinear: Bool) -> String {
        var accessibilityParts = ""
        if isLinear, isRequired {
            accessibilityParts += String(format: String(localized: "%@ Course %@. "), ordinalString(from: index), name)
        } else {
            accessibilityParts += String(format: String(localized: "Course name is %@. "), name)
        }
        accessibilityParts += String(format: String(localized: "Status %@. "), status.name)

         if status == .inProgress {
             accessibilityParts += String.localizedStringWithFormat(
                 String(localized: "Progress: %d percent complete. ", bundle: .horizon),
                 Int(round(completionPercent * 100))
             )
        }

        if let estimatedTime = estimatedTime {
            accessibilityParts += String(format: String(localized: "Estimated time is %@. "), estimatedTime)
        }
        accessibilityParts.append(isRequired ? String(localized: "Required course") : String(localized: "Optional course"))

        return accessibilityParts
    }

    func accessiblityHintString(status: ProgramCardStatus) -> String {
        switch status {
        case .notEnrolled: String(localized: "Double tap to enroll course")
        case .locked: String(localized: "This course is dimmed")
        default: String(localized: "Double tap to open course")
        }
    }
}

extension ProgramCourse {
    enum Status: String {
        case locked = "BLOCKED"
        case notEnrolled = "NOT_ENROLLED"
        case enrolled = "ENROLLED"
    }
}

extension Array where Element == ProgramCourse {
    func applyIndex() -> [ProgramCourse] {
        var counter = 0
        return self.map { course in
            var updatedCourse = course
            if course.isRequired {
                counter += 1
                updatedCourse.index = counter
            } else {
                updatedCourse.index = 0
            }
            return updatedCourse
        }
    }

    func mapToProgramSwitcher(programID: String?, programName: String?) -> [ProgramSwitcherModel.Course] {
        return self.map {
            .init(
                id: $0.id,
                name: $0.name,
                programID: programID,
                programName: programName,
                isEnrolled: $0.isEnrolled
            )
        }
    }
}
