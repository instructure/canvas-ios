//
// Copyright (C) 2019-present Instructure, Inc.
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
import CoreData

public final class QuizSubmission: NSManagedObject {
    @NSManaged public var attempt: Int
    @NSManaged public var attemptsLeft: Int
    @NSManaged public var endAt: Date?
    @NSManaged public var finishedAt: Date?
    @NSManaged public var id: String
    @NSManaged public var quiz: Quiz?
    @NSManaged public var quizID: String
    @NSManaged public var startedAt: Date?
    @NSManaged public var submissionID: String
    @NSManaged public var userID: String
    @NSManaged var workflowStateRaw: String

    public var workflowState: QuizSubmissionWorkflowState {
        get { return QuizSubmissionWorkflowState(rawValue: workflowStateRaw) ?? .untaken }
        set { workflowStateRaw = newValue.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIQuizSubmission, in context: NSManagedObjectContext) -> QuizSubmission {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Submission.id), item.id.value)
        let model: QuizSubmission = context.fetch(predicate).first ?? context.insert()
        model.attempt = item.attempt
        model.attemptsLeft = item.attempts_left
        model.endAt = item.end_at
        model.finishedAt = item.finished_at
        model.id = item.id.value
        model.quizID = item.quiz_id.value
        model.startedAt = item.started_at
        model.submissionID = item.submission_id.value
        model.userID = item.user_id.value
        model.workflowState = item.workflow_state
        return model
    }
}

extension QuizSubmission {
    public var canResume: Bool {
        return startedAt != nil && finishedAt == nil && endAt ?? Date.distantFuture > Date()
    }
}
