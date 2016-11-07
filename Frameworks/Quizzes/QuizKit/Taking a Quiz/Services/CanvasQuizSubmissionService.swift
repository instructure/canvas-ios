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
