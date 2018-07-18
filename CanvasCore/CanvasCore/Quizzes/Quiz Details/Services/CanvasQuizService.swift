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
    
    

import Foundation



import Result

import CoreData

class CanvasQuizService: QuizService {
    init(session: Session, context: ContextID, quizID: String) {
        self.session = session
        self.context = context
        self.quizID = quizID
        self.fileUploader = Uploader(session: session, apiPath: context.apiPath/"quizzes/\(quizID)/submissions/self/files")
    }
    
    let context: ContextID
    let quizID: String
    let fileUploader: Uploader
    
    let session: Session
    var user: SessionUser {
        return session.user
    }
    var apiPath: String {
        return context.apiPath/"quizzes/\(quizID)"
    }
    
    var baseURL: URL {
        return session.baseURL
    }
    
    // MARK: Quiz Requests
    func getQuiz(_ completed: @escaping (QuizResult)->()) {
        let _ = makeRequest(quizRequest(), completed: completed)
    }
    
    func getSubmissions(_ completed: @escaping (QuizSubmissionsResult)->()) {
        let _ = makeRequest(submissionsRequest(), completed: completed)
    }
    
    func beginNewSubmission(_ completed: @escaping (QuizSubmissionResult)->()) {
        let _ = makeRequest(postSubmissionRequest(), completed: completed)
    }
    
    func completeSubmission(_ submission: QuizSubmission, completed: @escaping (QuizSubmissionResult)->()) {
        let completion: (QuizSubmissionResult) -> () = { [weak self] result in
            if let _ = result.error {
            } else {
                if let me = self {
                    let submitted = Progress(kind: .submitted, contextID: me.context, itemType: .quiz, itemID: me.quizID)
                    me.session.progressDispatcher.dispatch(submitted)
                    let scored = Progress(kind: .minimumScore, contextID: me.context, itemType: .quiz, itemID: me.quizID)
                    me.session.progressDispatcher.dispatch(scored)
                }
            }
            completed(result)
        }
        let _ = makeRequest(completeSubmissionRequest(submission), completed: completion)
    }
    
    func submissionsRequest() -> Request<[QuizSubmission]> {
        let path = apiPath/"submissions"
        return Request(auth: session, method: .GET, path: path, parameters: nil, parseResponse: extractSubmissions)
    }
    
    func postSubmissionRequest() -> Request<QuizSubmission> {
        let path = apiPath/"submissions"
        return Request(auth: session, method: .POST, path: path, parameters: nil, parseResponse: extractFirstSubmission)
    }
    
    func completeSubmissionRequest(_ submission: QuizSubmission) -> Request<QuizSubmission> {
        let path = apiPath/"submissions/\(submission.id)/complete"
        let params: [String: Any] = [
            "attempt": submission.attempt,
            "validation_token": submission.validationToken,
            // TODO: access codes: "access_token": <access token>
        ]

        return Request(auth: session, method: .POST, path: path, parameters: params, parseResponse: extractFirstSubmission)
    }
    
    func quizRequest() -> Request<Quiz> {
        return Request(auth: session, method: .GET, path: apiPath as String, parameters: nil) { json in
            return Quiz.fromJSON(json).map {
                return Result(value: $0)
            } ?? Result(error: NSError.quizErrorWithMessage("Error parsing the quiz response"))
        }
    }

    func uploadSubmissionFile(_ uploadable: Uploadable, completed: @escaping (QuizSubmissionFileResult) -> ()) {
        do {
            try self.fileUploader.upload(uploadable, completed: completed)
        } catch let error as NSError {
            completed(Result(error: error))
        }
    }

    func cancelUploadSubmissionFile() {
        self.fileUploader.cancel()
    }

    func findFile(withID id: String) -> File? {
        do {
            let context = try self.session.filesManagedObjectContext()
            let predicate = NSPredicate(format: "%K == %@", "id", id)
            return try context.findOne(withPredicate: predicate)
        } catch {
            return nil
        }
    }
    
    func serviceForSubmission(_ submission: QuizSubmission) -> QuizSubmissionService {
        return CanvasQuizSubmissionService(auth: session, submission:submission)
    }
    
    func serviceForTimedQuizSubmission(_ submission: QuizSubmission) -> TimedQuizSubmissionService {
        return CanvasTimedQuizSubmissionService(auth: session, submission: submission, context: context, quizID: quizID)
    }
    
    func serviceForAuditLoggingSubmission(_ submission: QuizSubmission) -> SubmissionAuditLoggingService {
        return CanvasSubmissionAuditLoggingService(auth: session, apiPath: self.apiPath + "/submissions/\(submission.id)")
    }
}

private func extractSubmissions(_ json: Any?) -> Result<[QuizSubmission], NSError> {
    let jsonObject = json as? [String: Any]
    let array = jsonObject?["quiz_submissions"] as? [Any]
    
    return array.flatMap { array in
        return Result(value: decodeArray(array))
        } ?? Result(error: NSError.quizErrorWithMessage("Error parsing submissions"))
}

private func extractFirstSubmission(_ json: Any?) -> Result<QuizSubmission, NSError> {
    let arrayResult = extractSubmissions(json)
    return arrayResult.flatMap { arrayOfSubmissions in
        return arrayOfSubmissions.first.map {
            return Result(value: $0)
            } ?? Result(error: NSError.quizErrorWithMessage("Error parsing the posted submission"))
    }
}
