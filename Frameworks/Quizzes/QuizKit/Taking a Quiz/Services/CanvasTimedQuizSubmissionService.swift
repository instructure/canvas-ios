//
//  CanvasTimedQuizSubmissionService.swift
//  Quizzes
//
//  Created by Ben Kraus on 4/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import Result



class CanvasTimedQuizSubmissionService: TimedQuizSubmissionService {
    
    let auth: Session
    let submission: Submission
    let context: ContextID
    let quizID: String
    
    init(auth: Session, submission: Submission, context: ContextID, quizID: String) {
        self.auth = auth
        self.submission = submission
        self.context = context
        self.quizID = quizID
    }
    
    func getTimeRemaining(completed: TimeRemainingResult -> ()) {
        makeRequest(requestToGetTimeRemaining()) { pageResult in
            completed(pageResult.map { page in
                return page.content
            })
        }
    }
    
    private func requestToGetTimeRemaining() -> Request<Int> {
        let path = context.apiPath/"quizzes"/quizID/"submissions"/submission.id/"time"
        
        return Request(auth: auth, method: .GET, path: path, parameters: nil) { jsonValue in
            let object = jsonValue as? [String: AnyObject]
            if let timeLeft = object?["time_left"] as? Int {
                return Result(value: timeLeft)
            }
            return Result(error: NSError.quizErrorWithMessage("Error parsing timed quiz time at path \(path)"))
        }
    }
}