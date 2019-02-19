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
