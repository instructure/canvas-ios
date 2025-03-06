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
    public let settings: ScoresCourseSettings

    public init(
        courseID: String,
        enrollments: [ScoresCourseEnrollment],
        settings: ScoresCourseSettings
    ) {
        self.courseID = courseID
        self.enrollments = enrollments
        self.settings = settings
    }

    public init(from entity: CDScoresCourse) {
        self.courseID = entity.courseID
        self.enrollments = entity.enrollments.map(ScoresCourseEnrollment.init(from:))
        if let settings = entity.settings {
            self.settings = .init(from: settings)
        } else {
            self.settings = .init(
                restrictQuantitativeData: false,
                hideFinalGrade: false
            )
        }
    }
}
