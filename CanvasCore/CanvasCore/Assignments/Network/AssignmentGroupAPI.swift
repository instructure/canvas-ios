//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
