//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
