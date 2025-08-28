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

@testable import Core
@testable import Teacher

public final class GradeStateInteractorMock: GradeStateInteractor {

    private(set) var gradeStateCallsCount = 0
    private(set) var gradeStateInput: (submission: Submission, assignment: Assignment, isRubricScoreAvailable: Bool, totalRubricScore: Double)?
    var gradeStateOutput: GradeState?

    public func gradeState(
        submission: Submission,
        assignment: Assignment,
        gradingScheme: GradingScheme?,
        isRubricScoreAvailable: Bool,
        totalRubricScore: Double
    ) -> GradeState {
        gradeStateInput = (submission, assignment, isRubricScoreAvailable, totalRubricScore)
        gradeStateCallsCount += 1
        return gradeStateOutput ?? .empty
    }
}
