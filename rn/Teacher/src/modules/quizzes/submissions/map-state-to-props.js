// @flow

import { type SubmissionRowDataProps } from '../../submissions/list/SubmissionRow'
import { gradeProp, statusProp } from '../../submissions/list/get-submissions-props'
import { type QuizSubmissionListDataProps } from './QuizSubmissionList'

export function buildRows (enrollments: Enrollment[], quizSubmissions: { [string]: QuizSubmissionState }, submissions: { [string]: SubmissionState }): SubmissionRowDataProps[] {
  return enrollments.map((enrollment) => {
    const { user } = enrollment
    const quizSubmission = quizSubmissions[user.id]
    const submissionState = submissions[user.id]
    let grade = 'not_submitted'
    let status = 'none'
    let score
    let dueAt

    if (quizSubmission && quizSubmission.data) {
      score = quizSubmission.data.kept_score
      dueAt = quizSubmission.data.end_at
    }

    // If there is an actual submission object
    if (submissionState && submissionState.submission) {
      const submission = submissionState.submission
      grade = gradeProp(submission)
      status = statusProp(submission, dueAt)
    } else if (quizSubmission && quizSubmission.data) {
      status = 'submitted'
      const data = quizSubmission.data
      const keptScore = data.kept_score
      if (keptScore !== null && keptScore !== undefined) {
        grade = String(keptScore)
      }

      if (data.workflow_state === 'pending_review') {
        grade = 'ungraded'
      }

      if (Date.parse(data.end_at) < Date.now()) {
        status = 'late'
      }
    }

    return {
      userID: user.id,
      avatarURL: user.avatar_url,
      name: user.name,
      status,
      grade,
      score,
      anonymous: false, // this will be done in another commit
    }
  })
}

export default function mapStateToProps ({ entities }: AppState, { courseID, quizID }: any): QuizSubmissionListDataProps {
  let quiz = entities.quizzes[quizID]
  let quizSubmissions: { [string]: QuizSubmissionState } = {}
  let submissions: { [string]: SubmissionState } = {}
  let enrollments: Enrollment[] = []
  let pending = false
  let error = null
  let pointsPossible = 0

  if (quiz) {
    pending = Boolean(quiz.pending)
    pointsPossible = quiz.data.points_possible
    quiz.quizSubmissions.refs.map((r) => {
      return entities.quizSubmissions[r]
    })
    .filter((s) => s)
    .forEach((s) => { quizSubmissions[s.data.user_id] = s })

    quiz.submissions.refs.map((r) => {
      return entities.submissions[r]
    })
    .filter((s) => s)
    .forEach((s) => { submissions[s.submission.user_id] = s })
  }

  const course = entities.courses[courseID]
  if (course) {
    enrollments = course.enrollments.refs.map((r) => {
      return entities.enrollments[r]
    })
    .filter((r) => r)
    .filter((r) => r.type === 'StudentEnrollment')
  }

  const rows = buildRows(enrollments, quizSubmissions, submissions)

  return {
    rows,
    quiz,
    pending,
    pointsPossible,
    error,
  }
}
