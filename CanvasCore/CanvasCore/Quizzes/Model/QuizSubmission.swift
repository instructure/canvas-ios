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


import Marshal

struct QuizSubmission {
    init(id: String, dateStarted: Date?, dateFinished: Date?, endAt: Date?, attempt: Int, attemptsLeft: Int, validationToken: String, workflowState: WorkflowState) {
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
    let dateStarted: Date?
    let dateFinished: Date?
    let endAt: Date?
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

func ==(lhs: QuizSubmission.WorkflowState, rhs: QuizSubmission.WorkflowState) -> Bool {
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


extension QuizSubmission.WorkflowState: JSONDecodable {
    static func fromJSON(_ json: Any?) -> QuizSubmission.WorkflowState? {
        return (json as? String).flatMap { return QuizSubmission.WorkflowState(rawValue: $0) }
    }
}

extension QuizSubmission : JSONDecodable {
    static func fromJSON(_ json: Any?) -> QuizSubmission? {
        let jsonObject = json as? NSDictionary
        if let
            id = idString(jsonObject?["id"]),
            let attempt = jsonObject?["attempt"] as? Int,
            let attemptsLeft = jsonObject?["attempts_left"] as? Int,
            let validationToken = jsonObject?["validation_token"] as? String,
            let workflowState = QuizSubmission.WorkflowState.fromJSON(jsonObject?["workflow_state"]) {
                
                return QuizSubmission(id: id, dateStarted: Date.fromJSON(jsonObject?["started_at"]), dateFinished: Date.fromJSON(jsonObject?["finished_at"]), endAt: Date.fromJSON(jsonObject?["end_at"]), attempt: attempt, attemptsLeft: attemptsLeft, validationToken: validationToken, workflowState: workflowState)
        }
        
        return nil
    }
}
