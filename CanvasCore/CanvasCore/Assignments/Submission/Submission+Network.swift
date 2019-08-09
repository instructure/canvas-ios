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

import ReactiveSwift
import Marshal

extension Submission {
    static func getStudentSubmissions(_ session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try SubmissionAPI.getStudentSubmissions(session, courseID: courseID, assignmentID: assignmentID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    static func getSubmission(_ session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try SubmissionAPI.getSubmission(session, courseID: courseID, assignmentID: assignmentID)
        
        return session.JSONSignalProducer(request)
    }
}
