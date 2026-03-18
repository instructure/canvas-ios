//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import SwiftUI

struct WeeklySummaryWidgetAssignment: Identifiable {
    let id: String
    let courseId: String
    let courseCode: String
    let courseColor: Color
    let icon: Image
    let title: String
    let dueDateText: String?
    let submissionStatus: SubmissionStatusLabel.Model?
    let pointsPossible: String?
    let grade: String?
    let gradeWeightText: String?

    init(
        id: String,
        courseId: String,
        courseCode: String,
        courseColor: Color,
        icon: Image,
        title: String,
        dueDateText: String?,
        submissionStatus: SubmissionStatusLabel.Model?,
        pointsPossible: String?,
        grade: String?,
        gradeWeightText: String?
    ) {
        self.id = id
        self.courseId = courseId
        self.courseCode = courseCode
        self.courseColor = courseColor
        self.icon = icon
        self.title = title
        self.dueDateText = dueDateText
        self.submissionStatus = submissionStatus
        self.pointsPossible = pointsPossible
        self.grade = grade
        self.gradeWeightText = gradeWeightText
    }

    init(entry: CDDashboardWeeklySummaryEntry) {
        let course = entry.course
        let icon: Image
        if entry.isQuizLti {
            icon = .quizLine
        } else if entry.submissionTypes.contains(.discussion_topic) {
            icon = .discussionLine
        } else if entry.submissionTypes.contains(.external_tool) || entry.submissionTypes.contains(.basic_lti_launch) {
            icon = .ltiLine
        } else {
            icon = .assignmentLine
        }

        let grade: String? = entry.category != .missing ? Self.formatGradeFromEntry(entry) : nil
        let dueDateText: String? = entry.category == .newGrades ? nil : entry.dueAt?.dateTimeString

        let submissionStatus: SubmissionStatusLabel.Model?
        switch (entry.category, entry.submissionStatus) {
        case (.due, .graded):
            submissionStatus = .graded
        case (.due, .submitted):
            submissionStatus = .submitted
        default:
            submissionStatus = nil
        }

        self.init(
            id: entry.assignmentId,
            courseId: entry.courseId,
            courseCode: course?.courseCode ?? "",
            courseColor: course.map { Color($0.color) } ?? .course1,
            icon: icon,
            title: entry.title,
            dueDateText: dueDateText,
            submissionStatus: submissionStatus,
            pointsPossible: Self.formatPoints(entry.pointsPossible),
            grade: grade,
            gradeWeightText: entry.gradeWeight.map { Self.formatWeightPercent($0) }
        )
    }

    private static func formatGradeFromEntry(_ entry: CDDashboardWeeklySummaryEntry) -> String? {
        if entry.excused {
            return String(localized: "Excused", bundle: .student)
        }
        guard let grade = entry.grade, !grade.isEmpty else { return nil }
        if entry.restrictQuantitativeData {
            return grade
        }
        if entry.gradingType == "points" {
            guard let score = entry.score else { return grade }
            return numberFormatter.string(from: GradeFormatter.truncate(score)) ?? "\(score)"
        }
        if let numericGrade = Double(grade) {
            return numberFormatter.string(from: GradeFormatter.truncate(numericGrade))
        }
        return grade
    }

    private static func formatPoints(_ points: Double?) -> String? {
        guard let points else { return nil }
        return "\(numberFormatter.string(from: GradeFormatter.truncate(points)) ?? "\(points)") pts"
    }

    private static func formatWeightPercent(_ weight: Double) -> String {
        let percent = percentFormatter.string(from: NSNumber(value: weight)) ?? "\(weight * 100)%"
        return "\(percent) of final grade"
    }
}

private let numberFormatter = GradeFormatter.numberFormatter
private let percentFormatter = GradeFormatter.percentFormatter
