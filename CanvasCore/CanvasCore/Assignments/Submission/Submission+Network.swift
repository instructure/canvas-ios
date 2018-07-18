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

    static func post(_ newSubmission: NewSubmission, session: Session, courseID: String, assignmentID: String, comment: String?) throws -> SignalProducer<JSONObject, NSError> {
        let path = "/api/v1/courses/\(courseID)/assignments/\(assignmentID)/submissions"
        let parameters = Session.rejectNilParameters(["submission": newSubmission.parameters, "comment": comment])
        let request = try session.POST(path, parameters: parameters)
        return session.JSONSignalProducer(request)
    }
}

// Objective-C compatible bridge, cuz `NewSubmission` is an enum, and not compatible...
public extension Submission {
    @objc public static func submitArcSubmission(_ url: URL, session: Session, courseID: String, assignmentID: String, completion: @escaping (NSError?)->()) {
        let newSubmission = NewSubmission.arc(url)
        do {
            let sp = try post(newSubmission, session: session, courseID: courseID, assignmentID: assignmentID, comment: nil)
            sp.startWithSignal { signal, disposable in
                signal.observe(on: UIScheduler()).observeResult { result in
                    if case .failure(let error) = result {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        } catch let error as NSError {
            completion(error)
        }
        
    }
}
