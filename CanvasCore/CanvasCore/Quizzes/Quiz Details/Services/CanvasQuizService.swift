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

import Foundation
import CoreData

typealias QuizSubmissionsResult = Result<ResponsePage<[QuizSubmission]>, NSError>
typealias QuizSubmissionResult = Result<ResponsePage<QuizSubmission>, NSError>
typealias QuizResult = Result<ResponsePage<Quiz>, NSError>

class CanvasQuizService {
    init(session: Session, context: Context, quizID: String) {
        self.session = session
        self.context = context
        self.quizID = quizID
    }
    
    let context: Context
    let quizID: String
    
    let session: Session
    var user: SessionUser {
        return session.user
    }
    var apiPath: String {
        return "/api/v1/\(context.pathComponent)/quizzes/\(quizID)"
    }
    
    var baseURL: URL {
        return session.baseURL
    }

    func pageViewName() -> String {
        return baseURL.appendingPathComponent("\(context.pathComponent)/quizzes/\(quizID)").absoluteString
    }
    
    // MARK: Quiz Requests
    func getQuiz(_ completed: @escaping (QuizResult)->()) {
        let _ = makeRequest(quizRequest(), completed: completed)
    }

    func getSubmission(_ completed: @escaping (QuizSubmissionResult)->()) {
        let _ = makeRequest(submissionRequest(), completed: completed)
    }
    
    func getSubmissions(_ completed: @escaping (QuizSubmissionsResult)->()) {
        let _ = makeRequest(submissionsRequest(), completed: completed)
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
        let path = "\(apiPath)/submissions"
        return Request(auth: session, method: .GET, path: path, parameters: nil, parseResponse: extractSubmissions)
    }

    func submissionRequest() -> Request<QuizSubmission> {
        let path = "\(apiPath)/submission"
        return Request(auth: session, method: .GET, path: path, parameters: nil, parseResponse: extractFirstSubmission)
    }
    
    func completeSubmissionRequest(_ submission: QuizSubmission) -> Request<QuizSubmission> {
        let path = "\(apiPath)/submissions/\(submission.id)/complete"
        let params: [String: Any] = [
            "attempt": submission.attempt,
            "validation_token": submission.validationToken,
            // TODO: access codes: "access_token": <access token>
        ]

        return Request(auth: session, method: .POST, path: path, parameters: params, parseResponse: extractFirstSubmission)
    }
    
    func quizRequest() -> Request<Quiz> {
        return Request(auth: session, method: .GET, path: apiPath, parameters: nil) { json in
            return Quiz.fromJSON(json).map {
                return .success($0)
            } ?? .failure(NSError.quizErrorWithMessage("Error parsing the quiz response"))
        }
    }
    
    func serviceForTimedQuizSubmission(_ submission: QuizSubmission) -> CanvasTimedQuizSubmissionService {
        return CanvasTimedQuizSubmissionService(auth: session, submission: submission, context: context, quizID: quizID)
    }
}

private func extractSubmissions(_ json: Any?) -> Result<[QuizSubmission], NSError> {
    let jsonObject = json as? [String: Any]
    let array = jsonObject?["quiz_submissions"] as? [Any]
    
    return array.flatMap { array in
        return .success(decodeArray(array))
        } ?? .failure(NSError.quizErrorWithMessage("Error parsing submissions"))
}

private func extractFirstSubmission(_ json: Any?) -> Result<QuizSubmission, NSError> {
    let arrayResult = extractSubmissions(json)
    return arrayResult.flatMap { arrayOfSubmissions in
        return arrayOfSubmissions.first.map {
            return .success($0)
            } ?? .failure(NSError.quizErrorWithMessage("Error parsing the posted submission"))
    }
}
