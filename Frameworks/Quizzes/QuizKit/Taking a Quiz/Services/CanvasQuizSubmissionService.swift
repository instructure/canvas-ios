//
//  CanvasQuizSubmissionService.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/17/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import Result

import SoLazy

class CanvasQuizSubmissionService: QuizSubmissionService {
    
    init(auth: Session, submission: Submission) {
        self.auth = auth
        self.submission = submission
        
        print("service for submission \(submission.id)")  
    }
    
    private var submissionPath: String {
        return api/v1/"quiz_submissions"/submission.id
    }
    
    let auth: Session
    let submission: Submission

    func getQuestions(completed: SubmissionQuestionsResult->()) {
        makeRequest(submissionQuestionsRequest(), completed: completed)
    }
    
    func selectAnswer(answer: SubmissionAnswer, forQuestion: SubmissionQuestion, completed: SelectAnswerResult -> ()) {
        makeRequest(requestToSelectAnswer(answer, forQuestion: forQuestion), completed: completed)
    }
    
    func markQuestionFlagged(question: SubmissionQuestion, flagged: Bool, completed: FlagQuestionResult->()) {
        makeRequest(requestToMarkQuestionFlagged(question, flagged: flagged), completed: completed)
    }
    
    func requestToSelectAnswer(answer: SubmissionAnswer, forQuestion question: SubmissionQuestion) -> Request<Bool> {
        let path = submissionPath + "/questions"
        
        let params: [String: AnyObject] = [
            "attempt": submission.attempt,
            "validation_token": submission.validationToken,
            "quiz_questions": [["id": question.question.id, "answer": answer.apiAnswer]]
        ]

        return Request(auth: auth, method: .POST, path: path, parameters: params) { any in
            return Result(value: true)
        }
    }
    
    func submissionQuestionsRequest() -> Request<[SubmissionQuestion]> {
        let path = api/v1/"quiz_submissions"/submission.id/"questions"
        
        return Request(auth: auth, method: .GET, path: path, parameters: nil) { jsonValue in
            let object = jsonValue as? [String: AnyObject]
            if let array = object?["quiz_submission_questions"] as? [AnyObject] {
                let decoded: [SubmissionQuestion] = decodeArray(array)
                return Result(value: decoded)
            }
            
            return Result(error: NSError.quizErrorWithMessage("Error parsing questions at path \(path)"))
        }
    }
    
    func requestToMarkQuestionFlagged(question: SubmissionQuestion, flagged: Bool) -> Request<Bool> {
        let status = flagged ? "flag" : "unflag"
        let path = api/v1/"quiz_submissions"/submission.id/"questions"/question.question.id/status
        
        let params: [String: AnyObject] = [
            "attempt": submission.attempt,
            "validation_token": submission.validationToken
        ]
        
        return Request(auth: auth, method: .PUT, path: path, parameters: params) { jsonValue in
            return Result(value: true)
        }
    }
}
