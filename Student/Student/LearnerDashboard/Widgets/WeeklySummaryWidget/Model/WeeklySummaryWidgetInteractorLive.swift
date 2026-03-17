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

import Combine
import Core
import Foundation
import SwiftUI

final class WeeklySummaryWidgetInteractorLive: WeeklySummaryWidgetInteractor {

    private let env: AppEnvironment

    init(env: AppEnvironment = .shared) {
        self.env = env
    }

    func getSummary(weekStart: Date, ignoreCache: Bool) -> AnyPublisher<WeeklySummaryWidgetFilters, Error> {
        let useCase = GetWeeklySummaryEntries(
            weekStart: weekStart,
            studentId: env.currentSession?.userID ?? ""
        )
        return ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: ignoreCache)
            .receive(on: DispatchQueue.main)
            .map { [weak self] entries -> WeeklySummaryWidgetFilters in
                guard let self else { return WeeklySummaryWidgetFilters(missing: [], due: [], newGrades: []) }
                return WeeklySummaryWidgetFilters(
                    missing: entries.filter { $0.category == .missing }.map(mapEntryToAssignment),
                    due: entries.filter { $0.category == .due }.map(mapEntryToAssignment),
                    newGrades: entries.filter { $0.category == .newGrades }.map(mapEntryToAssignment)
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Mapping

    private func mapEntryToAssignment(_ entry: CDDashboardWeeklySummaryEntry) -> WeeklySummaryWidgetAssignment {
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

        let grade: String? = entry.category == .newGrades ? Self.formatGradeFromEntry(entry) : nil
        let dueDateText: String? = entry.category == .newGrades ? nil : entry.dueAt?.dateTimeString

        return WeeklySummaryWidgetAssignment(
            id: entry.assignmentId,
            courseId: entry.courseId,
            courseCode: course?.courseCode ?? "",
            courseColor: course.map { Color($0.color) } ?? .course1,
            icon: icon,
            title: entry.title,
            dueDateText: dueDateText,
            pointsPossible: Self.formatPoints(entry.pointsPossible),
            grade: grade,
            gradeWeightText: entry.gradeWeight.map { Self.formatWeightPercent($0) }
        )
    }

    // MARK: - Grade Formatting (pure)

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

    // MARK: - Formatting Helpers (pure)

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
