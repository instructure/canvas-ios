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
    
    



open class AssignmentGroupAPI {

    open class func getAssignmentGroups(_ session: Session, courseID: String, gradingPeriodID: String? = nil) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/assignment_groups"

        var parameters = Assignment.parameters
        var include = parameters["include"] as? [String] ?? []

        if let gradingPeriodID = gradingPeriodID {
            parameters["grading_period_id"] = gradingPeriodID
            parameters["scope_assignments_to_student"] = true // ignored by server if user is not a student
            include.append("assignments")
        }

        parameters["include"] = include

        return try session.GET(path, parameters: parameters)
    }

}
