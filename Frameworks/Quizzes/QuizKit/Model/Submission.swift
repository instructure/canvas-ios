//
//  QuizSubmission.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 1/6/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoLazy
import Marshal

struct Submission {
    init(id: String, dateStarted: NSDate?, dateFinished: NSDate?, endAt: NSDate?, attempt: Int, attemptsLeft: Int, validationToken: String, workflowState: WorkflowState) {
        self.id = id
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
        self.endAt = endAt
        self.attempt = attempt
        self.attemptsLeft = attemptsLeft
        self.validationToken = validationToken
        self.workflowState = workflowState
    }
    
    let id: String
    let dateStarted: NSDate?
    let dateFinished: NSDate?
    let endAt: NSDate?
    let attempt: Int
    let attemptsLeft: Int
    let validationToken: String
    let workflowState: WorkflowState
    
    enum WorkflowState: String, Equatable {
        case Untaken = "untaken"
        case PendingReview = "pending_review"
        case Complete = "complete"
        case SettingsOnly = "settings_only"
        case Preview = "preview"
    }
}

func ==(lhs: Submission.WorkflowState, rhs: Submission.WorkflowState) -> Bool {
    switch (lhs, rhs) {
    case
        (.Untaken, .Untaken),
        (.PendingReview, .PendingReview),
        (.Complete, .Complete),
        (.SettingsOnly, .SettingsOnly),
        (.Preview, .Preview):
        return true
        
    default:
        return false
    }
}


extension Submission.WorkflowState: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Submission.WorkflowState? {
        return (json as? String).flatMap { return Submission.WorkflowState(rawValue: $0) }
    }
}

extension Submission : JSONDecodable {
    static func fromJSON(json: AnyObject?) -> Submission? {
        let jsonObject = json as? NSDictionary
        if let
            id = idString(jsonObject?["id"]),
            attempt = jsonObject?["attempt"] as? Int,
            attemptsLeft = jsonObject?["attempts_left"] as? Int,
            validationToken = jsonObject?["validation_token"] as? String,
            workflowState = Submission.WorkflowState.fromJSON(jsonObject?["workflow_state"]) {
                
                return Submission(id: id, dateStarted: NSDate.fromJSON(jsonObject?["started_at"]), dateFinished: NSDate.fromJSON(jsonObject?["finished_at"]), endAt: NSDate.fromJSON(jsonObject?["end_at"]), attempt: attempt, attemptsLeft: attemptsLeft, validationToken: validationToken, workflowState: workflowState)
        }
        
        return nil
    }
}
