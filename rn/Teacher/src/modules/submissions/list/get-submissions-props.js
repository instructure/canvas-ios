// @flow

import type {
  SubmissionDataProps,
  GradeProp,
  SubmissionStatusProp,
  AsyncSubmissionsDataProps,
} from './submission-prop-types'
import localeSort from '../../../utils/locale-sort'

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

function statusProp (submission: ?Submission, dueDate: ?string): SubmissionStatusProp {
  if (!submission || submission.workflow_state === 'unsubmitted') {
    if (dueDate && (new Date(dueDate) < new Date())) {
      return 'missing'
    } else {
      return 'none'
    }
  }

  if (submission.late) {
    return 'late'
  } else {
    return 'submitted'
  }
}

function gradeProp (submission: ?Submission): GradeProp {
  if (!submission ||
    (submission.workflow_state === 'unsubmitted' &&
     !submission.excused)) {
    return 'not_submitted'
  }

  if (submission.excused) {
    return 'excused'
  }

  if (submission.grade) {
    return submission.grade
  }

  return 'ungraded'
}

function submissionProps (user: User, submission: ?SubmissionWithHistory, dueDate: ?string): SubmissionDataProps {
  const userID = user.id
  const avatarURL = user.avatar_url
  const name = user.name
  const status = statusProp(submission, dueDate)
  const grade = gradeProp(submission)
  let submissionID
  if (submission) {
    submissionID = submission.id
  }
  return { userID, avatarURL, name, status, grade, submissionID }
}

function dueDate (state: ?AssignmentDetailState): ?string {
  if (!state || !state.data) {
    return null
  }
  return state.data.due_at
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
  const due = dueDate(entities.assignments[assignmentID])

  // enrollments
  const courseContent = entities.courses[courseID]
  const enrollments = getEnrollments(courseContent, entities.enrollments)

  // submissions
  const assignmentContent = entities.assignments[assignmentID]
  const submissionsByUserID = getSubmissionsByUserID(assignmentContent, entities.submissions)

  const submissions = uniqueEnrollments(enrollments)
    .filter(enrollment => {
      return enrollment.type === 'StudentEnrollment'
    })
    .map(enrollment => {
      const submission: ?SubmissionWithHistory = submissionsByUserID[enrollment.user_id]
      return submissionProps(enrollment.user, submission, due)
    })
    .sort((s1, s2) => localeSort(s1.name, s2.name))

  const pending = pendingProp(assignmentContent, courseContent)

  return {
    submissions,
    pending,
  }
}
