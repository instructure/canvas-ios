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
    
    




open class SubmissionAPI {
    
    open class func getStudentSubmissions(_ session: Session, courseID: String, assignmentID: String) throws -> URLRequest {
        let path = ContextID.course(withID: courseID).apiPath/"assignments"/assignmentID/"submissions"
        
        return try session.GET(path, parameters: Submission.parameters)
    }
    
    open class func getSubmission(_ session: Session, courseID: String, assignmentID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(session.user.id)"
        let parameters = Submission.parameters
        
        return try session.GET(path, parameters: parameters)
    }
    
}   
