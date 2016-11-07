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
