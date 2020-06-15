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

open class SubmissionAPI {
    
    open class func getStudentSubmissions(_ session: Session, courseID: String, assignmentID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/assignments/\(assignmentID)/submissions"
        return try session.GET(path, parameters: Submission.parameters)
    }
    
    open class func getSubmission(_ session: Session, courseID: String, assignmentID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(session.user.id)"
        let parameters = Submission.parameters
        
        return try session.GET(path, parameters: parameters)
    }
    
}   
