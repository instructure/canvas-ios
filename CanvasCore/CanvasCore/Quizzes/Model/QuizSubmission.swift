//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

struct QuizSubmission {
    init(id: String, dateStarted: Date?, dateFinished: Date?, endAt: Date?, attempt: Int, attemptsLeft: Int, validationToken: String, workflowState: WorkflowState, extraTime: Int) {
        self.id = id
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
        self.endAt = endAt
        self.attempt = attempt
        self.attemptsLeft = attemptsLeft
        self.validationToken = validationToken
        self.workflowState = workflowState
        self.extraTime = extraTime
    }
    
    let id: String
    let dateStarted: Date?
    let dateFinished: Date?
    let endAt: Date?
    let attempt: Int
    let attemptsLeft: Int
    let validationToken: String
    let workflowState: WorkflowState
    let extraTime: Int
    
    enum WorkflowState: String, Equatable {
        case Untaken = "untaken"
        case PendingReview = "pending_review"
        case Complete = "complete"
        case SettingsOnly = "settings_only"
        case Preview = "preview"
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
            let attemptsLeft = jsonObject?["attempts_left"] as? Int,
            let validationToken = jsonObject?["validation_token"] as? String,
            let workflowState = QuizSubmission.WorkflowState.fromJSON(jsonObject?["workflow_state"]) {
                
                return QuizSubmission(
                    id: id,
                    dateStarted: Date.fromJSON(jsonObject?["started_at"]),
                    dateFinished: Date.fromJSON(jsonObject?["finished_at"]),
                    endAt: Date.fromJSON(jsonObject?["end_at"]),
                    attempt: jsonObject?["attempt"] as? Int ?? 0,
                    attemptsLeft: attemptsLeft,
                    validationToken: validationToken,
                    workflowState: workflowState,
                    extraTime: jsonObject?["extra_time"] as? Int ?? 0
                )
        }
        
        return nil
    }
}
