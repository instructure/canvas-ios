//
// Copyright (C) 2018-present Instructure, Inc.
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
import RealmSwift

public class GetAssignment: DetailUseCase<GetAssignmentRequest, Assignment> {
    let assignmentID: String

    public init(courseID: String, assignmentID: String, env: AppEnvironment = .shared) {
        self.assignmentID = assignmentID
        let request = GetAssignmentRequest(courseID: courseID, assignmentID: assignmentID)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Assignment.id), assignmentID)
    }

    override func updateModel(_ model: Assignment, using item: APIAssignment, in client: Persistence) throws {
        if model.id.isEmpty { model.id = item.id.value }
        model.name = item.name
        model.courseID = item.course_id.value
        model.content = item.description
        model.pointsPossible = item.points_possible
        model.dueAt = item.due_at
        model.htmlUrl = item.html_url
        model.gradingType = item.grading_type
        model.submissionTypes = item.submission_types
        if let submissionItem = item.submission {
            let submission = model.submission ?? client.insert()
            if submission.id.isEmpty { submission.id = submissionItem.id.value }
            submission.assignmentID = submissionItem.assignment_id.value
            submission.grade = submissionItem.grade
            submission.score = submissionItem.score
            submission.submittedAt = submissionItem.submitted_at
            submission.late = submissionItem.late
            submission.excused = submissionItem.excused
            submission.missing = submissionItem.missing
            submission.workflowState = submissionItem.workflow_state
            submission.latePolicyStatus = submissionItem.late_policy_status
            submission.pointsDeducted = submissionItem.points_deducted
            model.submission = submission
        } else {
            if let submission = model.submission {
                try client.delete(submission)
            }
        }
    }
}
