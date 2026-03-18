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
        let icon: Image = {
            if entry.isQuizLti {
                .quizLine
            } else if entry.submissionTypes.contains(.discussion_topic) {
                .discussionLine
            } else if entry.submissionTypes.contains(.external_tool) || entry.submissionTypes.contains(.basic_lti_launch) {
                .ltiLine
            } else {
                .assignmentLine
            }
        }()

        let grade: String? = {
            if entry.category == .missing {
                return nil
            }
            let normalizedScore: Double? = entry.score.flatMap { score in
                guard let pp = entry.pointsPossible, pp > 0 else { return nil }
                return score / pp
            }
            return GradeFormatter.string(
                pointsPossible: entry.pointsPossible,
                gradingType: GradingType(rawValue: entry.gradingType ?? "") ?? .points,
                gradingScheme: entry.course?.gradingScheme,
                hideScores: entry.restrictQuantitativeData,
                style: .medium,
                isExcused: entry.excused,
                score: entry.score,
                normalizedScore: normalizedScore,
                grade: entry.grade
            )
        }()
        let dueDateText: String? = entry.category == .newGrades ? nil : entry.dueAt?.dateTimeString

        let submissionStatus: SubmissionStatusLabel.Model? = {
            switch (entry.category, entry.submissionStatus) {
            case (.due, .graded): .graded
            case (.due, .submitted): .submitted
            default: nil
            }
        }()

        self.init(
            id: entry.assignmentId,
            courseId: entry.courseId,
            courseCode: course?.courseCode ?? "",
            courseColor: course.map { Color($0.color) } ?? .course1,
            icon: icon,
            title: entry.title,
            dueDateText: dueDateText,
            submissionStatus: submissionStatus,
            pointsPossible: String.format(ptsOrNil: entry.pointsPossible),
            grade: grade,
            gradeWeightText: entry.gradeWeight.map { Self.formatWeightPercent($0) }
        )
    }

    private static func formatWeightPercent(_ weight: Double) -> String {
        let percent = GradeFormatter.percentFormatter.string(from: NSNumber(value: weight)) ?? "\(weight * 100)%"
        return "\(percent) of final grade"
    }
}
