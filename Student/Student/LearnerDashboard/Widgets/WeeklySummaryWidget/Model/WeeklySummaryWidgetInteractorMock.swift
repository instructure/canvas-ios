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
import SwiftUI

final class WeeklySummaryWidgetInteractorMock: WeeklySummaryWidgetInteractor {

    var outputValue = WeeklySummaryWidgetFilters(
        missing: [],
        due: [
            WeeklySummaryWidgetAssignment(
                id: "1",
                courseId: "101",
                courseCode: "COGS101",
                courseColor: .course2,
                icon: .quizLine,
                title: "Chapter 5 Quiz",
                dueDateText: "Tomorrow at 11:59 PM",
                submissionStatus: nil,
                pointsPossible: "20 pts",
                grade: nil,
                gradeWeightText: nil
            ),
            WeeklySummaryWidgetAssignment(
                id: "2",
                courseId: "204",
                courseCode: "POLI204",
                courseColor: .course5,
                icon: .assignmentLine,
                title: "Policy Analysis Essay",
                dueDateText: "Thu at 11:59 PM",
                submissionStatus: nil,
                pointsPossible: "100 pts",
                grade: nil,
                gradeWeightText: "20% of final grade"
            ),
            WeeklySummaryWidgetAssignment(
                id: "3",
                courseId: "150",
                courseCode: "ENVS150",
                courseColor: .course8,
                icon: .assignmentLine,
                title: "Lab Report: Water Quality",
                dueDateText: "Sat at 11:59 PM",
                submissionStatus: nil,
                pointsPossible: "50 pts",
                grade: nil,
                gradeWeightText: nil
            )
        ],
        newGrades: [
            WeeklySummaryWidgetAssignment(
                id: "4",
                courseId: "101",
                courseCode: "COGS101",
                courseColor: .course2,
                icon: .assignmentLine,
                title: "Midterm Reflection",
                dueDateText: nil,
                submissionStatus: nil,
                pointsPossible: nil,
                grade: "85 pts",
                gradeWeightText: "30% of final grade"
            ),
            WeeklySummaryWidgetAssignment(
                id: "5",
                courseId: "204",
                courseCode: "POLI204",
                courseColor: .course5,
                icon: .assignmentLine,
                title: "Discussion Board Week 4",
                dueDateText: nil,
                submissionStatus: nil,
                pointsPossible: nil,
                grade: "15 pts",
                gradeWeightText: nil
            )
        ]
    )

    var outputError: Error?

    func clearCache() -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    var hasCachedSummaryOutput: Bool = false

    func hasCachedSummary(weekStart: Date) -> AnyPublisher<Bool, Never> {
        Just(hasCachedSummaryOutput).eraseToAnyPublisher()
    }

    func getSummary(weekStart: Date, ignoreCache: Bool) -> AnyPublisher<WeeklySummaryWidgetFilters, Error> {
        if let error = outputError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Publishers.typedJust(outputValue)
    }
}
