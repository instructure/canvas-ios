//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import CoreData

extension CDDashboardWeeklySummaryEntry {

    @discardableResult
    static func saveMissing(
        _ assignment: APIAssignment,
        weekStart: Date,
        gradeWeight: Double?,
        in context: NSManagedObjectContext
    ) -> CDDashboardWeeklySummaryEntry {
        let model = findOrCreate(weekStart: weekStart, category: .missing, id: assignment.id.rawValue, in: context)
        model.weekStart = weekStart
        model.category = .missing
        model.routeAssignmentId = assignment.id.rawValue
        model.courseId = assignment.course_id.rawValue
        model.course = context.first(where: #keyPath(Course.id), equals: assignment.course_id.rawValue)
        model.title = assignment.name
        model.date = assignment.due_at
        model.pointsPossible = assignment.points_possible
        model.isQuizLti = assignment.quiz_id != nil || assignment.is_quiz_lti_assignment == true
        model.submissionTypes = assignment.submission_types
        model.gradeWeight = gradeWeight
        model.grade = nil
        model.score = nil
        model.excused = false
        model.gradingType = nil
        model.restrictQuantitativeData = false
        model.submissionStatus = nil
        return model
    }

    @discardableResult
    static func saveDue(
        _ plannable: APIPlannable,
        assignment: APIAssignment,
        weekStart: Date,
        gradeWeight: Double?,
        in context: NSManagedObjectContext
    ) -> CDDashboardWeeklySummaryEntry {
        let model = findOrCreate(weekStart: weekStart, category: .due, id: plannable.plannable_id.value, in: context)
        model.weekStart = weekStart
        model.category = .due
        model.routeAssignmentId = assignment.id.rawValue
        model.courseId = plannable.context?.id ?? ""
        model.course = context.first(where: #keyPath(Course.id), equals: plannable.context?.id)
        model.title = plannable.plannable?.title ?? ""
        model.date = plannable.plannable_date
        model.pointsPossible = plannable.plannable?.points_possible
        model.isQuizLti = assignment.quiz_id != nil || assignment.is_quiz_lti_assignment == true
        model.submissionTypes = assignment.submission_types
        model.gradeWeight = gradeWeight
        let submission = assignment.submission?.values.first
        model.grade = submission?.grade
        model.score = submission?.score
        model.excused = submission?.excused == true
        model.gradingType = assignment.grading_type.rawValue
        model.restrictQuantitativeData = (context.first(where: #keyPath(Course.id), equals: plannable.context?.id) as Course?)?.settings?.restrictQuantitativeData ?? false
        let plannableSubmissions = plannable.submissions?.value1
        let status = Core.SubmissionStatus(
            isSubmitted: submission.map { $0.workflow_state != .unsubmitted } ?? (plannableSubmissions?.submitted == true),
            isGraded: submission?.grade != nil,
            isGradeBelongsToCurrentSubmission: submission?.grade_matches_current_submission ?? true,
            isLate: false,
            isMissing: false,
            isExcused: model.excused,
            customStatusId: nil,
            customStatusName: nil,
            submissionType: nil
        )
        if status.isGraded {
            model.submissionStatus = .graded
        } else if status.isSubmitted {
            model.submissionStatus = .submitted
        } else {
            model.submissionStatus = nil
        }
        model.discussionCheckpointStep = DiscussionCheckpointStep(
            tag: plannable.plannable?.sub_assignment_tag,
            requiredReplyCount: plannable.details?.reply_to_entry_required_count
        )
        return model
    }

    @discardableResult
    static func saveGrade(
        _ submission: GetRecentGradedSubmissionsRequest.Response.SubmissionNode,
        courseId: String,
        gradedAt: Date,
        weekStart: Date,
        restrictQuantitativeData: Bool,
        in context: NSManagedObjectContext
    ) -> CDDashboardWeeklySummaryEntry {
        let model = findOrCreate(weekStart: weekStart, category: .newGrades, id: submission.assignment._id, in: context)
        model.weekStart = weekStart
        model.category = .newGrades
        model.routeAssignmentId = submission.assignment._id
        model.courseId = courseId
        model.course = context.first(where: #keyPath(Course.id), equals: courseId)
        model.title = submission.assignment.name
        model.date = gradedAt
        model.pointsPossible = submission.assignment.pointsPossible
        model.isQuizLti = false
        model.submissionTypes = []
        model.gradeWeight = nil
        model.grade = submission.grade
        model.score = submission.score
        model.excused = submission.excused == true
        model.gradingType = submission.assignment.gradingType
        model.restrictQuantitativeData = restrictQuantitativeData
        model.submissionStatus = nil
        return model
    }
}
