//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

open class GradeAPI {
    open class func getGrades(_ session: Session, courseID: String, gradingPeriodID: String?) throws -> URLRequest {
        let path = api/v1/"courses/\(courseID)/enrollments"
        let parameters = Session.rejectNilParameters([
            "user_id": "self",
            "grading_period_id": gradingPeriodID,
            "enrollment_type": "student"
        ])

        return try session.GET(path, parameters: parameters)
    }
}
