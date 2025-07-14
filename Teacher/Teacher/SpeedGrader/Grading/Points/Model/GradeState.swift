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

import Core

struct GradeState: Equatable {
    let hasLateDeduction: Bool
    let isGraded: Bool
    let isExcused: Bool
    let isGradedButNotPosted: Bool
    let finalGradeText: String
    let gradeText: String
    let pointsDeductedText: String
    let gradeAlertText: String
    let score: Double

    init(
        hasLateDeduction: Bool,
        isGraded: Bool,
        isExcused: Bool,
        isGradedButNotPosted: Bool,
        finalGradeText: String,
        gradeText: String,
        pointsDeductedText: String,
        gradeAlertText: String,
        score: Double
    ) {
        self.hasLateDeduction = hasLateDeduction
        self.isGraded = isGraded
        self.isExcused = isExcused
        self.isGradedButNotPosted = isGradedButNotPosted
        self.finalGradeText = finalGradeText
        self.gradeText = gradeText
        self.pointsDeductedText = pointsDeductedText
        self.gradeAlertText = gradeAlertText
        self.score = score
    }

    init() {
        self.hasLateDeduction = false
        self.isGraded = false
        self.isExcused = false
        self.isGradedButNotPosted = false
        self.finalGradeText = ""
        self.gradeText = ""
        self.pointsDeductedText = ""
        self.gradeAlertText = ""
        self.score = 0
    }
}
