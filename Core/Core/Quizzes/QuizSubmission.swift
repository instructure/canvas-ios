//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData

public final class QuizSubmission: NSManagedObject {
    @NSManaged public var attempt: Int
    @NSManaged public var attemptsLeft: Int
    @NSManaged public var endAt: Date?
    @NSManaged public var extraTime: Double
    @NSManaged public var finishedAt: Date?
    @NSManaged public var id: String
    @NSManaged public var quiz: Quiz?
    @NSManaged public var quizID: String
    @NSManaged public var scoreRaw: NSNumber?
    @NSManaged public var startedAt: Date?
    @NSManaged public var submissionID: String
    @NSManaged public var userID: String
    @NSManaged public var validationToken: String?
    @NSManaged var workflowStateRaw: String

    public var workflowState: QuizSubmissionWorkflowState {
        get { return QuizSubmissionWorkflowState(rawValue: workflowStateRaw) ?? .untaken }
        set { workflowStateRaw = newValue.rawValue }
    }

    public var score: Double? {
        get { return scoreRaw?.doubleValue }
        set { scoreRaw = NSNumber(value: newValue) }
    }

    @discardableResult
    public static func save(_ item: APIQuizSubmission, in context: NSManagedObjectContext) -> QuizSubmission {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(QuizSubmission.id), item.id.value)
        let model: QuizSubmission = context.fetch(predicate).first ?? context.insert()
        model.attempt = item.attempt ?? 0
        model.attemptsLeft = item.attempts_left
        model.endAt = item.end_at
        model.extraTime = item.extra_time ?? 0
        model.finishedAt = item.finished_at
        model.id = item.id.value
        model.quizID = item.quiz_id.value
        model.score = item.score
        model.startedAt = item.started_at
        model.submissionID = item.submission_id.value
        model.userID = item.user_id.value
        model.validationToken = item.validation_token
        model.workflowState = item.workflow_state
        return model
    }

    public var canResume: Bool {
        return startedAt != nil && finishedAt == nil && endAt ?? .distantFuture > Clock.now
    }
}

public enum QuizSubmissionWorkflowState: String, Codable {
    case untaken, pending_review, complete, settings_only, preview
}
