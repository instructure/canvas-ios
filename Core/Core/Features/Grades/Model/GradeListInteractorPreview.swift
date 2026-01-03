//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

#if DEBUG

import Combine
import Foundation

final class GradeListInteractorPreview: GradeListInteractor {
    let context = PreviewEnvironment.shared.database.viewContext
    let isBaseDataLoaded = true

    func loadBaseData(ignoreCache: Bool) async throws -> GradeListGradingPeriodData {
        GradeListGradingPeriodData(
            course: Course.save(.make(), in: context),
            currentlyActiveGradingPeriodID: nil,
            gradingPeriods: []
        )
    }

    var courseID: String { "courseID" }

    func getGrades(arrangeBy: GradeArrangementOptions, baseOnGradedAssignment: Bool, gradingPeriodID: String?, ignoreCache: Bool) async throws -> GradeListData {
        GradeListData(
            id: UUID.string,
            userID: "userID",
            courseName: "2023 - Math",
            courseColor: nil,
            assignmentSections: [
                .init(
                    id: UUID.string,
                    title: "Overdue Assignments",
                    rows: (1...5).map {
                        let assignment = Assignment.save(.make(id: .init(integerLiteral: $0), name: "Assignment \($0)"), in: context, updateSubmission: false, updateScoreStatistics: false)
                        return .gradeListRow(.init(assignment: assignment, userId: "userID"))
                    }
                ),
                .init(
                    id: UUID.string,
                    title: "Upcoming Assignments",
                    rows: (6...8).map {
                        let assignment = Assignment.save(.make(id: .init(integerLiteral: $0), name: "Assignment \($0)"), in: context, updateSubmission: false, updateScoreStatistics: false)
                        return .gradeListRow(.init(assignment: assignment, userId: "userID"))
                    }
                ),
                .init(
                    id: UUID.string,
                    title: "Past Assignments",
                    rows: (9...10).map {
                        let assignment = Assignment.save(.make(id: .init(integerLiteral: $0), name: "Assignment \($0)"), in: context, updateSubmission: false, updateScoreStatistics: false)
                        return .gradeListRow(.init(assignment: assignment, userId: "userID"))
                    }
                )
            ],
            isGradingPeriodHidden: false,
            gradingPeriods: [
            ],
            currentGradingPeriod: .save(.make(), courseID: "courseID", in: context),
            totalGradeText: "80%"
        )
    }

    func updateGradingPeriod(id _: String?) {}
    func isWhatIfScoreFlagEnabled() -> Bool { true }
}

#endif
