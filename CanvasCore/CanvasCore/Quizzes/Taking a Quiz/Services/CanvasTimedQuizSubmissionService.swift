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

import Result



class CanvasTimedQuizSubmissionService: TimedQuizSubmissionService {
    
    let auth: Session
    let submission: QuizSubmission
    let context: ContextID
    let quizID: String
    
    init(auth: Session, submission: QuizSubmission, context: ContextID, quizID: String) {
        self.auth = auth
        self.submission = submission
        self.context = context
        self.quizID = quizID
    }
    
    func getTimeRemaining(_ completed: @escaping (TimeRemainingResult) -> ()) {
        let _ = makeRequest(requestToGetTimeRemaining()) { pageResult in
            completed(pageResult.map { page in
                return page.content
            })
        }
    }
    
    fileprivate func requestToGetTimeRemaining() -> Request<Int> {
        let path = context.apiPath/"quizzes"/quizID/"submissions"/submission.id/"time"
        
        return Request(auth: auth, method: .GET, path: path, parameters: nil) { jsonValue in
            let object = jsonValue as? [String: Any]
            if let timeLeft = object?["time_left"] as? Int {
                return Result(value: timeLeft)
            }
            return Result(error: NSError.quizErrorWithMessage("Error parsing timed quiz time at path \(path)"))
        }
    }
}
