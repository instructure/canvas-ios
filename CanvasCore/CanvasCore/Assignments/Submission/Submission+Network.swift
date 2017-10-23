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
