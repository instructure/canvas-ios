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

// @flow

import type {
  SubmissionDataProps,
  GradeProp,
  AsyncSubmissionsDataProps,
} from './submission-prop-types'
import localeSort from '../../../utils/locale-sort'
import find from 'lodash/find'
import { isTeacher } from '../../app'

function getEnrollments (courseContent?: CourseContentState, enrollments: EnrollmentsState): Array<Enrollment> {
  if (!courseContent) { return [] }
  return courseContent.enrollments.refs
    .map(ref => enrollments[ref])
}

function getSubmissionsByUserID (assignmentContent?: AssignmentContentState, submissions: SubmissionsState): { [string]: SubmissionWithHistory } {
  if (!assignmentContent) { return {} }
  return assignmentContent.submissions.refs
    .reduce((byUserID, ref) => {
      const submission = submissions[ref].submission
      if (!submission) { return byUserID }
      return { ...byUserID, [submission.user_id]: submission }
    }, {})
}

export function statusProp (submission: ?Submission, dueDate: ?string): ?SubmissionStatus {
  if (!submission || submission.workflow_state === 'unsubmitted' || submission.missing) {
    if (dueDate && (new Date(dueDate) < new Date())) {
      return 'missing'
    } else {
      return 'none'
    }
  }

  if (submission.late) {
    return 'late'
  } else if (submission.submission_type && submission.submission_type !== 'on_paper' && submission.submission_type !== 'none') {
    return 'submitted'
  }
}

export function gradeProp (submission: ?Submission): GradeProp {
  // a submission may be excused and (submitted or not submitted)
  // a submission may be graded and (submitted or not submitted)
  if (!submission) {
    return 'not_submitted'
  }

  if (submission.excused) {
    return 'excused'
  }

  if (!submission.submitted_at && !submission.grade) {
    return 'not_submitted'
  }

  if (submission.grade != null) {
    if (isTeacher()) {
      // Teachers only see the grade for the current submission
      if (submission.grade_matches_current_submission && submission.workflow_state !== 'pending_review') {
        // $FlowFixMe - It has already forgotten that submission.grade must be defined
        return submission.grade
      }
    } else {
      // Students always see the latest available grade
      // $FlowFixMe - It has already forgotten that submission.grade must be defined
      return submission.grade
    }
  }

  return 'ungraded'
}

function submissionProps (enrollment: Enrollment, submission: ?SubmissionWithHistory, dueDate: ?any, sectionIDs: { string: [string] }): SubmissionDataProps {
  let { user, course_section_id: sectionID } = enrollment
  const { id, name } = user
  const avatarURL = user.avatar_url
  const status = statusProp(submission, dueDate)
  const grade = gradeProp(submission)
  const score = submission ? submission.score : null
  const allSectionIDs = sectionIDs[id]
  let submissionID
  if (submission) {
    submissionID = submission.id
  }
  return { userID: id, avatarURL, name, status, grade, submissionID, submission, score, sectionID, allSectionIDs }
}

export function dueDate (assignment: Assignment, user: ?User | SessionUser): ?string {
  if (!assignment) {
    return null
  }

  const overrides = assignment.overrides
  if (overrides) {
    const override = find(overrides, (override) => {
      if (!override.student_ids) return false
      if (!user) return false
      return override.student_ids.includes(user.id)
    })
    if (override) {
      return override.due_at
    }
  }
  return assignment.due_at
}

function uniqueEnrollments (enrollments: Array<Enrollment>): Array<Enrollment> {
  const ids: Set<string> = new Set()
  return enrollments.reduce((unique, e) => {
    if (ids.has(e.user_id)) { return unique }
    ids.add(e.user_id)
    return [...unique, e]
  }, [])
}

export function pendingProp (assignmentContent?: AssignmentContentState, courseContent?: CourseContentState): boolean {
  if (!assignmentContent || !assignmentContent.submissions || !courseContent || !courseContent.enrollments) {
    return true // should be getting these things, so we'll say pending til they show up
  }

  return assignmentContent.submissions.pending > 0 || courseContent.enrollments.pending > 0
}

export function getSubmissionsProps (entities: Entities, courseID: string, assignmentID: string): AsyncSubmissionsDataProps {
  // enrollments
  const courseContent = entities.courses[courseID]
  const enrollments = getEnrollments(courseContent, entities.enrollments)

  const sectionIDs = enrollments.reduce((memo, enrollment) => {
    const userID = enrollment.user_id
    const existing = memo[userID] || []
    return { ...memo, [userID]: [...existing, enrollment.course_section_id] }
  }, {})

  // submissions
  const assignmentContent = entities.assignments[assignmentID]
  const submissionsByUserID = getSubmissionsByUserID(assignmentContent, entities.submissions)

  // don't create the submissions unless we have submissions
  // this fixes some issues we were having where deep linking
  // wouldn't show the submission for the user
  const submissions = Object.keys(submissionsByUserID).length
    ? uniqueEnrollments(enrollments)
      .filter(e => {
        return e.type === 'StudentEnrollment' &&
                (e.enrollment_state === 'active' ||
                e.enrollment_state === 'invited')
      })
      .sort((e1, e2) => {
        if (e1.type !== e2.type) {
          if (e1.type === 'StudentEnrollment') {
            return -1
          } else if (e2.type === 'StudentEnrollment') {
            return 1
          }
        }
        return localeSort(e1.user.sortable_name, e2.user.sortable_name)
      })
      .map(enrollment => {
        const submission: ?SubmissionWithHistory = submissionsByUserID[enrollment.user_id]
        const due = assignmentContent && dueDate(assignmentContent.data, enrollment.user)
        // $FlowFixMe
        let temp = submissionProps(enrollment, submission, due, sectionIDs)
        return temp
      })
    : []

  const pending = pendingProp(assignmentContent, courseContent)

  return {
    submissions,
    pending,
  }
}
