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



class CanvasQuizSubmissionService: QuizSubmissionService {
    
    init(auth: Session, submission: QuizSubmission) {
        self.auth = auth
        self.submission = submission
        
        print("service for submission \(submission.id)")  
    }
    
    fileprivate var submissionPath: String {
        return api/v1/"quiz_submissions"/submission.id
    }
    
    let auth: Session
    let submission: QuizSubmission

    func getQuestions(_ completed: @escaping (SubmissionQuestionsResult)->()) {
        let _ = makeRequest(submissionQuestionsRequest(), completed: completed)
    }
    
    func selectAnswer(_ answer: SubmissionAnswer, forQuestion: SubmissionQuestion, completed: @escaping (SelectAnswerResult) -> ()) {
        let _ = makeRequest(requestToSelectAnswer(answer, forQuestion: forQuestion), completed: completed)
    }
    
    func markQuestionFlagged(_ question: SubmissionQuestion, flagged: Bool, completed: @escaping (FlagQuestionResult)->()) {
        let _ = makeRequest(requestToMarkQuestionFlagged(question, flagged: flagged), completed: completed)
    }
    
    func requestToSelectAnswer(_ answer: SubmissionAnswer, forQuestion question: SubmissionQuestion) -> Request<Bool> {
        let path = submissionPath + "/questions"
        
        let params: [String: Any] = [
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
            let object = jsonValue as? [String: Any]
            if let array = object?["quiz_submission_questions"] as? [Any] {
                let decoded: [SubmissionQuestion] = decodeArray(array)
                return Result(value: decoded)
            }
            
            return Result(error: NSError.quizErrorWithMessage("Error parsing questions at path \(path)"))
        }
    }
    
    func requestToMarkQuestionFlagged(_ question: SubmissionQuestion, flagged: Bool) -> Request<Bool> {
        let status = flagged ? "flag" : "unflag"
        let path = api/v1/"quiz_submissions"/submission.id/"questions"/question.question.id/status
        
        let params: [String: Any] = [
            "attempt": submission.attempt,
            "validation_token": submission.validationToken
        ]
        
        return Request(auth: auth, method: .PUT, path: path, parameters: params) { jsonValue in
            return Result(value: true)
        }
    }
}
