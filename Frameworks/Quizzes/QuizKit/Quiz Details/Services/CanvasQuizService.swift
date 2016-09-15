//
//  CanvasQuizService.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 1/28/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import SoLazy
import SoProgressive

import Result

class CanvasQuizService: QuizService {
    init(session: Session, context: ContextID, quizID: String) {
        self.session = session
        self.context = context
        self.quizID = quizID
    }
    
    let context: ContextID
    let quizID: String
    
    let session: Session
    var user: SessionUser {
        return session.user
    }
    var apiPath: String {
        return context.apiPath/"quizzes/\(quizID)"
    }
    
    var baseURL: NSURL {
        return session.baseURL
    }
    
    // MARK: Quiz Requests
    func getQuiz(completed: QuizResult->()) {
        makeRequest(quizRequest(), completed: completed)
    }
    
    func getSubmissions(completed: QuizSubmissionsResult->()) {
        makeRequest(submissionsRequest(), completed: completed)
    }
    
    func beginNewSubmission(completed: QuizSubmissionResult->()) {
        makeRequest(postSubmissionRequest(), completed: completed)
    }
    
    func completeSubmission(submission: Submission, completed: QuizSubmissionResult->()) {
        let completion: QuizSubmissionResult -> () = { [weak self] result in
            if let _ = result.error {
            } else {
                if let me = self {
                    let submitted = Progress(kind: .Submitted, contextID: me.context, itemType: .Quiz, itemID: me.quizID)
                    me.session.progressDispatcher.dispatch(submitted)
                    let scored = Progress(kind: .MinimumScore, contextID: me.context, itemType: .Quiz, itemID: me.quizID)
                    me.session.progressDispatcher.dispatch(scored)
                }
            }
            completed(result)
        }
        makeRequest(completeSubmissionRequest(submission), completed: completion)
    }
    
    func submissionsRequest() -> Request<[Submission]> {
        let path = apiPath/"submissions"
        return Request(auth: session, method: .GET, path: path, parameters: nil, parseResponse: extractSubmissions)
    }
    
    func postSubmissionRequest() -> Request<Submission> {
        let path = apiPath/"submissions"
        return Request(auth: session, method: .POST, path: path, parameters: nil, parseResponse: extractFirstSubmission)
    }
    
    func completeSubmissionRequest(submission: Submission) -> Request<Submission> {
        let path = apiPath/"submissions/\(submission.id)/complete"
        let params: [String: AnyObject] = [
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
    
    func serviceForSubmission(submission: Submission) -> QuizSubmissionService {
        return CanvasQuizSubmissionService(auth: session, submission:submission)
    }
    
    func serviceForTimedQuizSubmission(submission: Submission) -> TimedQuizSubmissionService {
        return CanvasTimedQuizSubmissionService(auth: session, submission: submission, context: context, quizID: quizID)
    }
    
    func serviceForAuditLoggingSubmission(submission: Submission) -> SubmissionAuditLoggingService {
        return CanvasSubmissionAuditLoggingService(auth: session, apiPath: self.apiPath + "/submissions/\(submission.id)")
    }
}

private func extractSubmissions(json: AnyObject?) -> Result<[Submission], NSError> {
    let jsonObject = json as? [String: AnyObject]
    let array = jsonObject?["quiz_submissions"] as? [AnyObject]
    
    return array.flatMap { array in
        return Result(value: decodeArray(array))
        } ?? Result(error: NSError.quizErrorWithMessage("Error parsing submissions"))
}

private func extractFirstSubmission(json: AnyObject?) -> Result<Submission, NSError> {
    let arrayResult = extractSubmissions(json)
    return arrayResult.flatMap { arrayOfSubmissions in
        return arrayOfSubmissions.first.map {
            return Result(value: $0)
            } ?? Result(error: NSError.quizErrorWithMessage("Error parsing the posted submission"))
    }
}
