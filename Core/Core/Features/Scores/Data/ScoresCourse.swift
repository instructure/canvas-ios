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

public struct ScoresCourse {
    public let courseID: String
    public let enrollments: [ScoresCourseEnrollment]

    public init(courseID: String, enrollments: [ScoresCourseEnrollment]) {
        self.courseID = courseID
        self.enrollments = enrollments
    }

    public init(from entity: CDScoresCourse) {
        self.courseID = entity.courseID
        self.enrollments = entity.enrollments.map(ScoresCourseEnrollment.init(from:))
    }
}

public struct ScoresCourseEnrollment {
    public let courseID: String
    public let computedFinalScore: Double?
    public let computedFinalGrade: String?

    public init(
        courseID: String,
        computedFinalScore: Double?,
        computedFinalGrade: String?
    ) {
        self.courseID = courseID
        self.computedFinalScore = computedFinalScore
        self.computedFinalGrade = computedFinalGrade
    }

    init(from entity: CDScoresCourseEnrollment) {
        self.courseID = entity.courseID
        self.computedFinalGrade = entity.computedFinalGrade
        self.computedFinalScore = entity.computedFinalScore?.doubleValue
    }
}
