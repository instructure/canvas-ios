//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

// @flow

import type {
  SubmissionDataProps,
  GradeProp,
  AsyncSubmissionsDataProps,
} from './submission-prop-types'
import localeSort from '../../../utils/locale-sort'
import { isTeacher } from '../../app'

function getEnrollments (courseContent?: CourseContentState, enrollments: EnrollmentsState): Array<Enrollment> {
  if (!courseContent) { return [] }
  return courseContent.enrollments.refs
    .map(ref => enrollments[ref])
    .filter(e => e?.enrollment_state === 'active')
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
  const { id, sortable_name, pronouns } = user
  const avatarURL = user.avatar_url
  const status = statusProp(submission, dueDate)
  const grade = gradeProp(submission)
  const score = submission ? submission.score : null
  const allSectionIDs = sectionIDs[id]
  let submissionID
  if (submission) {
    submissionID = submission.id
  }
  return { userID: id, avatarURL, name: sortable_name, status, grade, submissionID, submission, score, sectionID, allSectionIDs, pronouns }
}

export function dueDate (assignment: Assignment, user: ?User | SessionUser, group: ?Group): ?string {
  if (!assignment) {
    return
  }

  const overrides = assignment.overrides
  if (!overrides) {
    return assignment.due_at
  }

  let override
  if (group) {
    override = overrides.find(override => {
      return override.group_id != null &&
             group &&
             override.group_id === group.id
    })
  } else {
    override = overrides.find(override => {
      if (!user) return false
      return (override.student_ids || []).includes(user.id)
    })
  }

  return override != null ? override.due_at : assignment.due_at
}

export function pendingProp (assignmentContent?: AssignmentContentState, courseContent?: CourseContentState): boolean {
  if (!assignmentContent || !assignmentContent.submissions || !courseContent || !courseContent.enrollments) {
    return true // should be getting these things, so we'll say pending til they show up
  }

  return assignmentContent.submissions.pending > 0 || courseContent.enrollments.pending > 0 || courseContent.groups.pending > 0
}

// If a submission does not have a grade or an actual submission it will not have a group attached to the submission.
// So if it's there we get the group from entities, but if not then we will look up the group in entities based on
// the category id and if the user is in the group.
export function getGroup (groups: GroupsState, submission: SubmissionWithHistory, categoryID: ?string): ?Group {
  if (submission.group && submission.group.id != null) {
    let group = groups[submission.group.id]
    if (!group) return
    return group.group
  }

  if (!categoryID) return

  // $FlowFixMe
  let groupValues: Array<{ group: Group }> = Object.values(groups)
  let group = groupValues
    .filter(({ group }) => group && group.group_category_id === categoryID)
    .find(({ group }) => group.users && group.users.map(({ id }) => id).includes(submission.user_id))

  if (!group) return
  return group.group
}

export function groupPropsForSubmissionsAndDueDate (submission: SubmissionWithHistory, dueDate: ?string, group: ?Group) {
  if (!group) return
  return {
    // just a precaution... we're filtering out empty groups below
    userID: group.users && group.users.length > 0 ? group.users[0].id : 'none',
    groupID: group.id,
    name: group.name,
    status: statusProp(submission, dueDate),
    grade: gradeProp(submission),
    score: submission ? submission.score : null,
    submissionID: submission ? submission.id : null,
    submission,
    sectionID: null,
    allSectionIDs: null,
  }
}

export function getSubmissionsProps (entities: Entities, courseID: string, assignmentID: string): AsyncSubmissionsDataProps {
  // enrollments
  const courseContent = entities.courses[courseID]
  const enrollments = getEnrollments(courseContent, entities.enrollments)

  const sectionIDs: { [string]: [string] } = enrollments.reduce((memo, enrollment) => {
    const userID = enrollment.user_id
    const existing = memo[userID] || []
    return { ...memo, [userID]: [...existing, enrollment.course_section_id] }
  }, {})

  // We no longer need to do the song and dance of matching user enrollments up to potentially missing
  // submissions since we now are guaranteed to have one submission per user/group. We also handle both
  // groups and users here since it's possible for a user to not be in a group so we can't do one or
  // the other, we must do both.
  const assignmentContent = entities.assignments[assignmentID]
  const submissions = Object.values(entities.submissions)
    // $FlowFixMe
    .map(({ submission }) => submission)
    .filter(sub => sub.assignment_id === assignmentID)
    .map(sub => {
      let group = getGroup(entities.groups, sub, assignmentContent.data.group_category_id)
      if (assignmentContent.data.group_category_id != null &&
          !assignmentContent.data.grade_group_students_individually &&
          group != null) {
        const due = assignmentContent != null ? dueDate(assignmentContent.data, null, group) : undefined
        return groupPropsForSubmissionsAndDueDate(sub, due, group)
      } else {
        const enrollment = enrollments.find(e => e.user_id === sub.user_id)
        if (!enrollment) {
          return
        }
        const due = assignmentContent && dueDate(assignmentContent.data, enrollment.user)
        return submissionProps(enrollment, sub, due, sectionIDs)
      }
    })
    .filter(Boolean)
    .sort((s1, s2) => {
      return localeSort(s1.name, s2.name)
    })

  const pending = pendingProp(assignmentContent, courseContent)

  return {
    submissions,
    pending,
  }
}
